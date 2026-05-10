import decman
from decman.plugins import pacman


class CodexModule(decman.Module):
    def __init__(self):
        super().__init__("codex")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "openai-codex",
        }
