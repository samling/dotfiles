import decman
from decman.plugins import pacman, aur


class CoreModule(decman.Module):

    def __init__(self):
        super().__init__("core")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "7zip",
            "aspell",
            "bash-completion",
            "bat",
            "bc",
            "btop",
            "chezmoi",
            "cmake",
            "cpio",
            "dua-cli",
            "duf",
            "eza",
            "fd",
            "file",
            "fx",
            "fzf",
            "glances",
            "glib2",
            "glow",
            "go-yq",
            "grc",
            "gron",
            "htop",
            "inotify-tools",
            "inxi",
            "jc",
            "jq",
            "libnotify",
            "lsd",
            "lsof",
            "man-pages",
            "markdownlint",
            "moreutils",
            "plocate",
            "psmisc",
            "ranger",
            "rhash",
            "ripgrep",
            "rsync",
            "s-nail",
            "tldr",
            "tree",
            "unrar",
            "unzip",
            "viu",
            "wget",
            "whois",
            "xxhash",
            "zip",
            "zoxide",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "crudini",
            "icat",
            "localsend-bin",
            "mmdr-bin",
            "ntfysh-bin",
            "timg",
            "neo-matrix",
            "toofan-bin",
            "viddy",
            # Custom packages from chezmoi pkgs/ — not yet on AUR; ship as
            # CustomPackage(pkgbuild_directory=...) once PKGBUILDs exist:
            #   gitoverit
        }
