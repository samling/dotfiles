import decman
from decman.plugins import aur, pacman


class GamesModule(decman.Module):
    """Steam + the firewall ports it needs for Remote Play.

    Requires multilib enabled in /etc/pacman.conf (it isn't by default
    on a stock Arch install). decman won't enable it for you.
    """

    def __init__(self):
        super().__init__("games")

    @pacman.packages
    def pkgs(self) -> set[str]:
        base = {
          "gamescope",
          "moonlight-qt",
          "steam",
        }
        return base

    @aur.packages
    def aurpkgs(self) -> set[str]:
        base = {
          "heroic-games-launcher-bin",
          "stepmania",
        }
        return base

    def files(self) -> dict[str, decman.File]:
        # firewalld zone drop-in. firewalld is already pulled in by
        # NetworkingModule. Reload happens via firewalld's own watcher
        # of /etc/firewalld/.
        return {
            "/etc/firewalld/services/steam-remote-play.xml": decman.File(
                content=(
                    '<?xml version="1.0" encoding="utf-8"?>\n'
                    '<service>\n'
                    '  <short>Steam Remote Play</short>\n'
                    '  <port port="27036" protocol="tcp"/>\n'
                    '  <port port="27031-27036" protocol="udp"/>\n'
                    '</service>\n'
                ),
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }
