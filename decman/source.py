import importlib
import socket

import decman

from modules.chezmoi import ChezmoiModule

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
    "python-installer",
    "python-pygments",
    "python-pyproject-hooks",
    "python-pytest",
    "python-pytest-mock",
    "python-setuptools",
    "python-setuptools-scm",
    "python-six",
    "python-tests",
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
