from pathlib import Path

import decman
from decman.plugins import pacman, aur

# Absolute path to the repo's pkgbuilds/ dir. decman chdirs into a
# temp build dir before copying PKGBUILDs, so relative paths break.
_PKGBUILDS = Path(__file__).resolve().parents[2] / "pkgbuilds"


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
            "cmatrix-git",
            "crudini",
            "fatrace",
            "icat",
            "localsend-bin",
            "mmdr-bin",
            "ntfysh-bin",
            "timg",
            "neo-matrix",
            "toofan-bin",
            "viddy",
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
