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
            "bc",
            "btop",
            "chezmoi",
            "cmake",
            "cmatrix",
            "duf",
            "eza",
            "fd",
            "file",
            "fzf",
            "glances",
            "glib2",
            "glow",
            "htop",
            "inotify-tools",
            "inxi",
            "jq",
            "libnotify",
            "lsd",
            "lsof",
            "man-pages",
            "moreutils",
            "plocate",
            "psmisc",
            "ranger",
            "read-edid",
            "rhash",
            "ripgrep",
            "rsync",
            "s-nail",
            "tldr",
            "tree",
            "unrar",
            "unzip",
            "v4l-utils",
            "wget",
            "whois",
            "xxhash",
            "yq",
            "zip",
            "zoxide",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "crudini",
            "toofan-bin",
            "viddy",
            # Custom packages from chezmoi pkgs/ — not yet on AUR; ship as
            # CustomPackage(pkgbuild_directory=...) once PKGBUILDs exist:
            #   gitoverit
        }
