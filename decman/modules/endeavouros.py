import decman
from decman.plugins import pacman


class EndeavourOSModule(decman.Module):

    def __init__(self):
        super().__init__("endeavouros")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "endeavouros-branding",
            "endeavouros-keyring",
            "endeavouros-mirrorlist",
            "eos-apps-info",
            "eos-hooks",
            "eos-hwtool",
            "eos-log-tool",
            "eos-packagelist",
            "eos-quickstart",
            "eos-rankmirrors",
            "welcome",
        }
