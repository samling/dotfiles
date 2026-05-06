import decman
from decman.plugins import pacman, aur


class DevModule(decman.Module):

    def __init__(self):
        super().__init__("dev")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "ansible",
            "clang",
            "direnv",
            "distrobox",
            "fnm",
            "gcc",
            "github-cli",
            "go",
            "just",
            "lazygit",
            "llvm",
            "luarocks",
            "make",
            "meld",
            "neovim",
            "nvm",
            "patchelf",
            "pyenv",
            "python",
            "python-defusedxml",
            "python-jinja",
            "python-packaging",
            "python-pillow",
            "python-pyqt5",
            "python-reportlab",
            "qmk",
            "uv",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "asdf-vm",
            # devbox-bin tracks Jetify's prebuilt release tarball; the
            # source-build `devbox` PKGBUILD has had recurring sha256
            # drift against upstream re-rolls.
            "devbox-bin",
            # pet-git's pkgver() returns `date +%Y%m%d`, which decman
            # can't match against the AUR-registered version, so the
            # build fails with "pkg file cannot be determined". The
            # non-git `pet-bin` ships a prebuilt binary with a static
            # version from upstream releases.
            "pet-bin",
            # qmk-udev-rules-git is broken (its PKGBUILD references
            # util/udev/50-qmk.rules which qmk_firmware no longer ships
            # at that path). The `qmk` pacman package above already
            # installs /usr/lib/udev/rules.d/50-qmk.rules, so the AUR
            # package is redundant anyway.
            "qmk-hid",
        }
