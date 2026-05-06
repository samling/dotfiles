from pathlib import Path

import decman
from decman.plugins import pacman, aur

# Absolute path to the repo's pkgbuilds/ dir. decman chdirs into a
# temp build dir before copying PKGBUILDs, so relative paths break.
_PKGBUILDS = Path(__file__).resolve().parents[2] / "pkgbuilds"


class SecurityModule(decman.Module):
    """CLI security tooling. Wireshark's Qt UI lives in gui_security.

    after_update bootstraps an auto-unlocking (empty-password)
    gnome-keyring login keyring for sboynton if one doesn't already
    exist. Standard across hosts: no PAM-driven keyring unlock is in
    use (WSL has no PAM login flow; the Niri compositor on xen
    doesn't run pam_gnome_keyring either). Trade-off: secrets are
    stored at-rest with no passphrase. Same trust boundary as
    ~/.aws/credentials, ~/.kube/config, ~/.ssh/id_*.
    """

    def __init__(self):
        super().__init__("security")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "bitwarden-cli",
            # Secret Service provider for libsecret consumers (doppler,
            # gh, vault, browser cookies). On WSL there's no PAM login
            # flow to auto-unlock, so on first use create the login
            # keyring with an empty password (see role docstring).
            "gnome-keyring",
            "seahorse", # keyring configurator
            "tailscale",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "doppler-cli-bin",
            "littlesnitch-bin",
            "trufflehog",
        }

    @aur.custom_packages
    def custompkgs(self) -> set[aur.CustomPackage]:
        return {
            # FalcoSuessgott/vkv has no AUR package. PKGBUILD pulls the
            # prebuilt binary from the GitHub release (same source the
            # old nix derivation used).
            aur.CustomPackage(
                pkgname="vkv-bin",
                pkgbuild_directory=str(_PKGBUILDS / "vkv-bin"),
            ),
        }

    def after_update(self, store):
        # Create the login keyring with an empty password so libsecret
        # consumers (doppler, gh, vault) can read/write without a
        # session unlock. Idempotent: bails if login.keyring exists,
        # so an existing passworded keyring is never overwritten.
        # Sets DBUS_SESSION_BUS_ADDRESS explicitly because su -l
        # doesn't always inherit it from the user's running session.
        decman.prg(
            [
                "bash", "-lc",
                'set -e\n'
                'kr="$HOME/.local/share/keyrings/login.keyring"\n'
                '[ -f "$kr" ] && exit 0\n'
                'mkdir -p "$(dirname "$kr")"\n'
                'export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus"\n'
                'gnome-keyring-daemon --replace --components=secrets,pkcs11 --unlock '
                '< /dev/null > /dev/null 2>&1\n'
            ],
            user="sboynton",
            mimic_login=True,
            check=False,
        )
