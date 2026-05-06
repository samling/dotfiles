import decman


class LocaleModule(decman.Module):
    """System locale + timezone.

    Mirrors the nix `common/locale.nix` settings. /etc/timezone isn't a
    real systemd file (timedatectl reads /etc/localtime → zoneinfo
    symlink); we set the symlink directly via tmpfiles-style File.
    """

    def __init__(self):
        super().__init__("locale")

    def files(self) -> dict[str, decman.File]:
        return {
            "/etc/locale.conf": decman.File(
                content=(
                    "LANG=en_US.UTF-8\n"
                    "LC_ADDRESS=en_US.UTF-8\n"
                    "LC_IDENTIFICATION=en_US.UTF-8\n"
                    "LC_MEASUREMENT=en_US.UTF-8\n"
                    "LC_MONETARY=en_US.UTF-8\n"
                    "LC_NAME=en_US.UTF-8\n"
                    "LC_NUMERIC=en_US.UTF-8\n"
                    "LC_PAPER=en_US.UTF-8\n"
                    "LC_TELEPHONE=en_US.UTF-8\n"
                    "LC_TIME=en_US.UTF-8\n"
                ),
                permissions=0o644,
                owner="root",
                group="root",
            ),
            "/etc/vconsole.conf": decman.File(
                content="KEYMAP=us\n",
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }

    def after_update(self, store):
        # Idempotent; timedatectl is a no-op if zone already matches.
        decman.prg(
            ["timedatectl", "set-timezone", "America/Los_Angeles"],
            check=False,
        )
