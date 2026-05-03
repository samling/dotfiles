import decman
from decman.plugins import pacman


class DevModule(decman.Module):

    def __init__(self):
        super().__init__("dev")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "clang",
            "direnv",
            "fnm",
            "meld",
            "neovim",
            "python",
            "python-defusedxml",
            "python-jinja",
            "python-packaging",
            "python-pillow",
            "python-pyqt5",
            "python-reportlab",
            "uv",
        }
