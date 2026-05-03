import decman
from decman.plugins import pacman, aur


class ShellModule(decman.Module):

    def __init__(self):
        super().__init__("shell")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "fastfetch",
            "tmux",
            "zsh",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "gitstatus-bin",
            "zinit",
            "zsh-pure-prompt",
        }
