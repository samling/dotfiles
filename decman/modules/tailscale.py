import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class TailscaleModule(decman.Module):
    """Tailscaled service + firewall-mode override + firewalld plumbing.

    The `tailscale` package itself is in SecurityModule. Putting it
    there alone leaves the daemon disabled — this module enables it
    and pins it to nftables (matching `modules/tailscale/tailscale.nix`).

    firewalld plumbing mirrors the nix config's
    `firewall.trustedInterfaces = ["tailscale0"]` and
    `firewall.allowedUDPPorts = [tailscale.port]`:
      - tailscale0 lives in the trusted zone, so peer traffic isn't
        filtered.
      - UDP/41641 is opened on whatever zone is active so peers can
        establish direct connections (DERP fallback works without it
        but pays a relay round-trip).
    """

    def __init__(self):
        super().__init__("tailscale")

    @pacman.packages
    def pkgs(self) -> set[str]:
        # nftables is already a hard dep of firewalld via iptables-nft
        # on most setups, but list it explicitly so removing firewalld
        # doesn't take it with it.
        return {"nftables"}

    @systemd.units
    def units(self) -> set[str]:
        return {"tailscaled.service"}

    def on_change(self, store):
        reconcile_units(self, store)

    def files(self) -> dict[str, decman.File]:
        return {
            "/etc/systemd/system/tailscaled.service.d/firewall-mode.conf": decman.File(
                content=(
                    "[Service]\n"
                    "Environment=TS_DEBUG_FIREWALL_MODE=nftables\n"
                ),
                permissions=0o644,
                owner="root",
                group="root",
            ),
            # Override firewalld's stock trusted zone to bind tailscale0.
            # Replaces /usr/lib/firewalld/zones/trusted.xml; the only
            # change vs. the upstream default is the <interface> entry.
            "/etc/firewalld/zones/trusted.xml": decman.File(
                content=(
                    '<?xml version="1.0" encoding="utf-8"?>\n'
                    '<zone target="ACCEPT">\n'
                    '  <short>Trusted</short>\n'
                    '  <description>All network connections are accepted.</description>\n'
                    '  <interface name="tailscale0"/>\n'
                    '</zone>\n'
                ),
                permissions=0o644,
                owner="root",
                group="root",
            ),
            # Custom firewalld service definition. Bound to a zone in
            # after_update via firewall-cmd; the file alone only
            # registers the service name + ports.
            "/etc/firewalld/services/tailscale.xml": decman.File(
                content=(
                    '<?xml version="1.0" encoding="utf-8"?>\n'
                    '<service>\n'
                    '  <short>Tailscale</short>\n'
                    '  <description>Tailscale WireGuard daemon (direct-connection port).</description>\n'
                    '  <port port="41641" protocol="udp"/>\n'
                    '</service>\n'
                ),
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }

    def after_update(self, store):
        # Skip if already bound so steady-state runs don't print
        # ALREADY_ENABLED noise. pty=False captures output silently
        # unless the command fails.
        already = decman.prg(
            ["firewall-cmd", "--permanent", "--zone=public",
             "--query-service=tailscale"],
            pty=False, check=False,
        ).strip() == "yes"
        if already:
            return
        # firewalld doesn't watch /etc/firewalld/services/, so reload
        # to pick up tailscale.xml before --add-service validates
        # against the loaded service list.
        decman.prg(["firewall-cmd", "--reload"], pty=False, check=False)
        decman.prg(
            ["firewall-cmd", "--permanent",
             "--zone=public", "--add-service=tailscale"],
            pty=False, check=False,
        )
