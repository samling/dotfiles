from decman.plugins import aur


class SemiUnattended(aur.AurCommands):
    """Suppress per-package interaction during AUR builds; keep pacman's
    overall install/upgrade/remove summary prompts intact.

    install/upgrade/remove are intentionally NOT overridden — they keep
    pacman's default behavior so the user-facing summary still prompts.
    """

    def review_file(self, file):
        return ["cat", file]

    def git_diff(self, from_commit):
        return ["git", "diff", "--stat", from_commit]

    def install_as_dependencies(self, pkgs):
        return ["pacman", "-S", "--needed", "--asdeps", "--noconfirm", *pkgs]

    def install_files_as_dependencies(self, pkg_files):
        return ["pacman", "-U", "--asdeps", "--noconfirm", *pkg_files]
