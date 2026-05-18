import decman
from decman.plugins import pacman, aur


class MediaGuiModule(decman.Module):
    """GUI media apps: image viewers, OBS, Spotify, media-key control.

    Split out of MediaModule so headless/WSL roles don't pull in GUI
    Electron/Qt apps. spotify's PKGBUILD has validpgpkeys; the
    AurKeysModule constructed by `roles.common._aur_keys` already
    fetches Spotify's signing key into the aurbuilder keyring, so
    nothing role-side is needed for the build to succeed.

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
            "darktable",
            "feh",
            "imv",
            "obs-studio",
            "playerctl",
            "rawtherapee",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "davinci-resolve",
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
        # Skip services already bound to the zone so steady-state runs
        # don't print ALREADY_ENABLED noise. pty=False captures output
        # silently unless the command fails.
        needed = [
            svc for svc in ("spotify-connect", "mdns")
            if decman.prg(
                ["firewall-cmd", "--permanent", "--zone=public",
                 f"--query-service={svc}"],
                pty=False, check=False,
            ).strip() != "yes"
        ]
        if not needed:
            return
        # firewalld doesn't watch /etc/firewalld/services/, so reload
        # to pick up spotify-connect.xml before --add-service validates
        # against the loaded service list.
        decman.prg(["firewall-cmd", "--reload"], pty=False, check=False)
        for svc in needed:
            decman.prg(
                ["firewall-cmd", "--permanent",
                 "--zone=public", f"--add-service={svc}"],
                pty=False, check=False,
            )
