import decman
from decman.plugins import pacman


class PrintingModule(decman.Module):

    def __init__(self):
        super().__init__("printing")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "cups",
            "cups-browsed",
            "cups-filters",
            "cups-pdf",
            "foomatic-db",
            "foomatic-db-engine",
            "foomatic-db-gutenprint-ppds",
            "foomatic-db-nonfree",
            "foomatic-db-nonfree-ppds",
            "foomatic-db-ppds",
            "ghostscript",
            "gutenprint",
            "hplip",
            "sane",
            "system-config-printer",
        }
