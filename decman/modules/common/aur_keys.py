"""GPGReceiver wrapper for AUR packages whose PKGBUILDs require PGP
signature verification (spotify, etc.).

decman builds AUR packages in a clean chroot as `decman.aur.makepkg_user`
(default `nobody`). When a PKGBUILD declares validpgpkeys, makepkg
checks signatures against that user's keyring inside the chroot —
empty by default, so the build fails with "SIGNATURE NOT FOUND" or
"key could not be looked up".

The fix is to keep the keys in a real user's gnupg home (nobody's
/var/empty isn't writable) and pass GNUPGHOME through to
makechrootpkg. Wiring:

  - UsersModule creates the `aurbuilder` system user with a real home.
  - source.py calls `AurKeysModule.configure()` which sets
    GNUPGHOME + decman.aur.makepkg_user.
  - `roles/common.py`'s `_aur_keys()` constructs an AurKeysModule
    instance, calls `fetch_spotify()` (and friends), and registers
    it through COMMON. Each role file places UsersModule before
    *COMMON, so before_update sees aurbuilder already extant.
    GPGReceiver silently no-ops if the user doesn't exist yet.
"""

import os

import decman
from decman.extras.gpg import GPGReceiver

from modules.common.users import (
    AUR_BUILDER_GNUPG_HOME,
    AUR_BUILDER_USER,
)


class AurKeysModule(GPGReceiver):

    DEFAULT_KEYSERVER = "hkps://keyserver.ubuntu.com"

    @classmethod
    def configure(cls) -> None:
        """Set process-wide env so makechrootpkg uses the aurbuilder
        keyring. Must run during source.py load, before any AUR plugin
        step. Safe to call multiple times.
        """
        os.environ["GNUPGHOME"] = AUR_BUILDER_GNUPG_HOME
        decman.aur.makepkg_user = AUR_BUILDER_USER

    def receive(self, fingerprint: str, keyserver: str = DEFAULT_KEYSERVER) -> None:
        """Pull a key from a keyserver into the aurbuilder keyring.

        The full 40-char fingerprint is required. Find the right one by
        cloning the AUR package and reading validpgpkeys:

            curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=<pkg>" | grep validpgpkeys

        Or `paru -G <pkg> && grep validpgpkeys <pkg>/PKGBUILD`. Don't
        use the short/long key ID that gpg prints in error messages —
        short IDs are spoofable and decman rejects them.
        """
        self.receive_key(
            user=AUR_BUILDER_USER,
            gpg_home=AUR_BUILDER_GNUPG_HOME,
            fingerprint=fingerprint,
            keyserver=keyserver,
        )

    def fetch_uri(self, fingerprint: str, uri: str) -> None:
        """Pull a key directly from an HTTP(S) URI. Use when the
        upstream publishes the key at a known stable location (e.g.
        Spotify's debian repo) instead of trusting a keyserver.
        """
        self.fetch_key(
            user=AUR_BUILDER_USER,
            gpg_home=AUR_BUILDER_GNUPG_HOME,
            fingerprint=fingerprint,
            uri=uri,
        )

    # Per-package helpers below. Adding a new one is a two-step process:
    # find the validpgpkeys fingerprint as documented in `receive()`,
    # then call `receive()` or `fetch_uri()` here.

    def fetch_spotify(self) -> None:
        # Spotify's debian-repo signing key (per decman/docs/extras.md).
        self.fetch_uri(
            fingerprint="E1096BCBFF6D418796DE78515384CE82BA52C83A",
            uri="https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.gpg",
        )

    def fetch_wlogout(self) -> None:
        # Haden Collins, AUR maintainer for wlogout.
        self.receive(fingerprint="F4FDB18A9937358364B276E9E25D679AF73C6D2F")
