import importlib
import os
import socket
import subprocess

import decman

from modules import _aur_prompts
from modules._aur_commands import SemiUnattended
from modules._pacman_commands import NoUpgrade
from modules.common.aur_keys import AurKeysModule
from modules.common.chezmoi import ChezmoiModule

# Skip per-package interaction during AUR builds (less pauses, dep prompts);
# pacman's overall install/upgrade/remove summary prompts are kept.
decman.aur.commands = SemiUnattended()

# Opt-out of pacman -Syu for this run. Useful when adding/removing
# packages whose closures you don't want to upgrade in the same apply.
# Usage: sudo DECMAN_NO_UPGRADE=1 decman
# (sudo strips env by default, hence inlining the var after sudo.)
if os.environ.get("DECMAN_NO_UPGRADE"):
    decman.pacman.commands = NoUpgrade()

# Auto-answer decman's per-package "Review PKGBUILD?" / "Build this package?"
# prompts. Top-level "Proceed?" prompts still ask.
_aur_prompts.install()

# Point AUR builds at the aurbuilder user's gpg keyring (created by
# UsersModule, populated by AurKeysModule). Has to happen before host
# modules load so makepkg's chroot sees the right env.
AurKeysModule.configure()

# Registered first so its before_update hook (chezmoi apply) runs before any
# host modules' updates. Module hooks fire in registration order.
decman.modules += [ChezmoiModule()]

# Toolchains and build tools we actively use. Declared so decman ensures
# they're installed and reinstalls if removed externally. Their forward-dep
# closures (zig→llvm20-libs, pandoc-cli→haskell-*, etc.) anchor the rest.
decman.pacman.packages |= {
    "meson",
    "ninja",
    "pandoc-cli",
    "rustup",
    "zig",
}

# Transitive Python build/test infra pulled in by AUR builds. ignored_packages
# preserves their existing --asdeps state and pacman's dep graph keeps them
# alive; we just don't want decman to GC them.
decman.pacman.ignored_packages |= {
    "python-build",
    "python-iniconfig",
    "python-installer",
    "python-pluggy",
    "python-pygments",
    "python-pyproject-hooks",
    "python-pytest",
    "python-pytest-mock",
    "python-setuptools",
    "python-setuptools-scm",
    "python-six",
    "python-tests",
    "python-vcs-versioning",
    "python-wheel",
}

_host = socket.gethostname()
_slug = _host.replace("-", "_").lower()

try:
    importlib.import_module(f"hosts.{_slug}")
except ModuleNotFoundError as e:
    if e.name != f"hosts.{_slug}":
        raise
    raise decman.SourceError(
        f"no host config for hostname {_host!r}; create hosts/{_slug}.py"
    )


# Auto-ignore every currently-installed `python-*` package that no
# declared module asks for. Decman's GC otherwise treats them as
# orphan-able when their original consumer (e.g. ufw) leaves the
# declared set, which is whack-a-mole: each removal cascades a new
# batch of jaraco / autocommand / pkg_resources / platformdirs /
# more-itertools / ... transitive deps into the remove list, and
# any one of those may have non-obvious reverse-deps outside our
# managed set.
#
# Intersect with the declared set so this DOESN'T block installs of
# python-* packages we actually declare (python-black, python-isort,
# python-jinja, python-pillow, ...): `ignored_packages` is also
# subtracted from `to_install` in `decman.plugins.pacman.apply`, so
# unconditionally ignoring would silently skip installing declared
# python pkgs that aren't on the host yet.
#
# Walks decman.modules directly here because `decman.pacman.packages`
# isn't populated until `plugin.process_modules` runs later in the
# apply lifecycle - well after source.py finishes evaluating.
def _declared_pacman_pkgs() -> set[str]:
    # Imported inside the function: decman runs source.py via
    # `exec(content)` from inside `_execute_source` (decman.app),
    # which makes module-level imports land in exec's local frame
    # rather than this function's __globals__. Looking up a
    # closure'd helper at call time then fails with NameError. Keep
    # the lookup local to dodge that.
    #
    # `decman/__init__.py` also rebinds `decman.plugins` to the
    # available_plugins() dict, shadowing the submodule attribute -
    # `import decman.plugins as p` or `from decman import plugins`
    # both yield the dict, not the submodule. Pull the helper out
    # by name to bypass the shadow.
    from decman.plugins import run_methods_with_attribute

    pkgs = set(decman.pacman.packages)
    for mod in decman.modules:
        pkgs |= set().union(*run_methods_with_attribute(mod, "__pacman__packages__"))
    return pkgs


try:
    _installed = set(
        subprocess.check_output(["pacman", "-Qq"], text=True).splitlines()
    )
except (FileNotFoundError, subprocess.CalledProcessError):
    # Pre-bootstrap (no pacman yet) or pacman db locked. Skip the
    # auto-ignore; the curated list above still covers the worst
    # offenders.
    _installed = set()

_declared = _declared_pacman_pkgs()
decman.pacman.ignored_packages |= {
    p for p in _installed if p.startswith("python-")
} - _declared
