"""GPGReceiver wrapper for AUR packages whose PKGBUILDs require PGP
signature verification (spotify, etc.).

decman builds AUR packages in a clean chroot as `decman.aur.makepkg_user`
(default `nobody`). When a PKGBUILD declares validpgpkeys, makepkg
checks signatures against that user's keyring inside the chroot -
empty by default, so the build fails with "SIGNATURE NOT FOUND" or
"key could not be looked up".

The fix is to keep the keys in a real user's gnupg home (nobody's
/var/empty isn't writable) and pass GNUPGHOME through to
makechrootpkg. Wiring:

  - UsersModule creates the `aurbuilder` system user with a real home.
  - source.py calls `AurKeysModule.configure()` which sets
    GNUPGHOME + decman.aur.makepkg_user.
  - `roles/common.py` adds an AurKeysModule instance to MODULES.
    AurKeysModule.__init__ reads aur_keys.toml (sibling file) and
    pre-registers every entry's fingerprint with GPGReceiver. Each
    role file places UsersModule before *COMMON, so before_update
    sees aurbuilder already extant. GPGReceiver silently no-ops if
    the user doesn't exist yet.

To add a new key: prefer `just sync-aur-keys` (auto-discovers from
PKGBUILDs, prompts y/N). Hand-edit aur_keys.toml only for entries
that need `uri = "..."` (non-keyserver fetches like Spotify's).
"""

import os
import tomllib
from pathlib import Path

import decman
from decman.extras.gpg import GPGReceiver

from modules.common.users import (
    AUR_BUILDER_GNUPG_HOME,
    AUR_BUILDER_USER,
)

_KEYS_TOML = Path(__file__).resolve().parent / "aur_keys.toml"


class AurKeysModule(GPGReceiver):

    DEFAULT_KEYSERVER = "hkps://keyserver.ubuntu.com"

    def __init__(self) -> None:
        super().__init__()
        for entry in self._load_entries():
            fingerprint = entry["fingerprint"]
            if "uri" in entry:
                self.fetch_key(
                    user=AUR_BUILDER_USER,
                    gpg_home=AUR_BUILDER_GNUPG_HOME,
                    fingerprint=fingerprint,
                    uri=entry["uri"],
                )
            else:
                self.receive_key(
                    user=AUR_BUILDER_USER,
                    gpg_home=AUR_BUILDER_GNUPG_HOME,
                    fingerprint=fingerprint,
                    keyserver=entry.get("keyserver", self.DEFAULT_KEYSERVER),
                )

    @classmethod
    def configure(cls) -> None:
        """Set process-wide env so makechrootpkg uses the aurbuilder
        keyring. Must run during source.py load, before any AUR plugin
        step. Safe to call multiple times.
        """
        os.environ["GNUPGHOME"] = AUR_BUILDER_GNUPG_HOME
        decman.aur.makepkg_user = AUR_BUILDER_USER

    @staticmethod
    def _load_entries() -> list[dict]:
        if not _KEYS_TOML.exists():
            return []
        with _KEYS_TOML.open("rb") as f:
            data = tomllib.load(f)
        return data.get("entries", [])
