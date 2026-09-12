from functools import wraps

from decman.core import output
from decman.plugins import aur
from decman.plugins.aur import fpm


class SemiUnattended(aur.AurCommands):
    """Suppress per-package interaction during AUR builds; keep pacman's
    overall install/upgrade/remove summary prompts intact.

    install/upgrade/remove are intentionally NOT overridden — they keep
    pacman's default behavior so the user-facing summary still prompts.
    """

    def review_file(self, file):
        return ["cat", file]

    def git_diff(self, from_commit):
        return [
            "git",
            "show",
            "--oneline",
            "--patch",
            "HEAD",
            "--",
            "PKGBUILD",
            ".SRCINFO",
        ]

    def install_as_dependencies(self, pkgs):
        return ["pacman", "-S", "--needed", "--asdeps", "--noconfirm", *pkgs]

    def install_files_as_dependencies(self, pkg_files):
        return ["pacman", "-U", "--asdeps", "--noconfirm", *pkg_files]


def install_cache(*, resume: bool = False) -> None:
    """Checkpoint builds; optionally reuse development builds on recovery.

    Hooks target Decman 1.2.2. Normal cache/version/force behavior is retained.
    Resume is not an update mode: it can reuse a VCS build with the same
    advertised version even if upstream has advanced. Decman still recreates
    the chroot and PKGBUILD checkout.
    """
    original_add = fpm.add_package_to_cache
    if not getattr(original_add, "__aur_cache_checkpoint__", False):
        @wraps(original_add)
        def checkpoint(store, package, version, path_to_built_pkg):
            original_add(store, package, version, path_to_built_pkg)
            # Store.save is atomic and respects dry-run. Persist after each
            # successfully copied archive, not just when the whole run exits.
            store.save()

        setattr(checkpoint, "__aur_cache_checkpoint__", True)
        fpm.add_package_to_cache = checkpoint

    if not resume:
        return

    original_cached = fpm.PackageBuilder._are_all_pkgs_cached
    if getattr(original_cached, "__aur_cache_resume__", False):
        return

    output.print_warning(
        "AUR resume enabled: reusing existing cached builds with matching package "
        "versions, including development packages. These may not contain the latest "
        "upstream commits. Omit DECMAN_AUR_RESUME for normal update behavior."
    )

    @wraps(original_cached)
    def cached(self, pkgs):
        if original_cached(self, pkgs):
            return True
        # Decman's normal check rejects all VCS packages. In explicit resume
        # mode use its same archive-exists + version-equals rule for those too.
        # build_packages still honors force and rebuilds the whole split base
        # if even one required output is missing or has a different version.
        for package in pkgs:
            entry = fpm.find_latest_cached_package(self._store, package.name)
            info = self._search.get_package_info(package.name)
            if entry is None or info is None or entry[0] != info.version:
                return False
        return bool(pkgs)

    setattr(cached, "__aur_cache_resume__", True)
    fpm.PackageBuilder._are_all_pkgs_cached = cached
