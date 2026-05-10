import decman
from decman.plugins import pacman, aur, systemd

from modules._systemd import reconcile_units


class BrowsersModule(decman.Module):
    """Web browsers + the chrome-graceful-shutdown shim.

    Chrome's main process writes `exit_type=Normal` to the profile only
    if it receives SIGTERM and runs its own shutdown. On reboot the
    session manager would SIGKILL it, so the next launch nagged "didn't
    shut down correctly". The user unit (defined in chezmoi's
    dot_config/systemd/user/) sends SIGTERM to the top-level chrome
    process at session-end and waits up to 6s for it to flush.
    """

    def __init__(self):
        super().__init__("browsers")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {"firefox"}

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"google-chrome"}

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        return {"sboynton": {"chrome-graceful-shutdown.service"}}

    def on_change(self, store):
        reconcile_units(self, store)
