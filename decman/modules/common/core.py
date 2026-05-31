import decman
from decman.plugins import pacman, aur

from modules._paths import PKGBUILDS as _PKGBUILDS


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
            "ncdu",
            "plocate",
            "psmisc",
            "qalculate-qt",
            "ranger",
            "rhash",
            "ripgrep",
            "rsync",
            "s-nail",
            "tealdeer",
            "tree",
            "unrar",
            "unzip",
            "viu",
            "wakeonlan",
            "wget",
            "whois",
            "xxhash",
            "zip",
            "zoxide",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "cmatrix-git",
            "crudini",
            "fatrace",
            "icat",
            "localsend-bin",
            "mmdr-bin",
            "ntfysh-bin",
            "smem",
            "timg",
            "neo-matrix",
            "toofan-bin",
            "viddy",
            "xembedsniproxy",
            # gitoverit still has no PKGBUILD; not yet on AUR.
        }

    @aur.custom_packages
    def custompkgs(self) -> set[aur.CustomPackage]:
        return {
            # samling/command-snippets, no AUR package. PKGBUILD pulls
            # the prebuilt binary from the GitHub release.
            aur.CustomPackage(
                pkgname="command-snippets-bin",
                pkgbuild_directory=str(_PKGBUILDS / "command-snippets-bin"),
            ),
        }
