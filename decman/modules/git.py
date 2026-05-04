import decman
from decman.plugins import pacman, aur


class GitModule(decman.Module):
    """git-adjacent CLI tooling. `git` itself lives in BaseModule and
    `github-cli` in DevModule; this is for the diff/status/hook layer.
    """

    def __init__(self):
        super().__init__("git")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "git-delta",
            "pre-commit",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"gitmux"}
