import decman
from decman.plugins import pacman, aur


class CoreModule(decman.Module):

    def __init__(self):
        super().__init__("core")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "aspell",
            "bash-completion",
            "bat",
            "btop",
            "chezmoi",
            "duf",
            "glances",
            "htop",
            "inxi",
            "jq",
            "lsd",
            "plocate",
            "rsync",
            "s-nail",
            "tldr",
            "unrar",
            "unzip",
            "wget",
            "whois",
            "yq",
            "zoxide",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"crudini"}
