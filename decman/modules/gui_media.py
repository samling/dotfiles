import decman
from decman.plugins import pacman, aur


class MediaGuiModule(decman.Module):
    """GUI media apps: image viewers, OBS, Spotify, media-key control.

    Split out of MediaModule so headless/WSL roles don't pull in GUI
    Electron/Qt apps. spotify's PKGBUILD has validpgpkeys; the role
    file must register AurKeysModule(.fetch_spotify()) before this
    module so the aurbuilder keyring contains Spotify's signing key
    by the time makechrootpkg fires.

    Spotify Connect needs TCP/57621 (peer sync) and UDP/5353 (mDNS
    discovery) reachable to talk to other devices on the LAN; the
    nix `spotify.nix` opened both. mDNS is firewalld's built-in
    service; spotify-connect is a custom service definition.
    """

    def __init__(self):
        super().__init__("gui_media")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "feh",
            "imv",
            "obs-studio",
            "playerctl",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "ie-r",
            "spotify",
        }

    def files(self) -> dict[str, decman.File]:
        return {
            "/etc/firewalld/services/spotify-connect.xml": decman.File(
                content=(
                    '<?xml version="1.0" encoding="utf-8"?>\n'
                    '<service>\n'
                    '  <short>Spotify Connect</short>\n'
                    '  <description>Spotify desktop client peer-sync port.</description>\n'
                    '  <port port="57621" protocol="tcp"/>\n'
                    '</service>\n'
                ),
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }

    def after_update(self, store):
        # Bind the Spotify Connect service + the built-in mDNS service
        # to the active zone. firewall-cmd writes the change to the
        # zone XML and firewalld's filesystem watcher reloads it.
        for svc in ("spotify-connect", "mdns"):
            decman.prg(
                [
                    "firewall-cmd", "--permanent",
                    "--zone=public", f"--add-service={svc}",
                ],
                check=False,
            )
