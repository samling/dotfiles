import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class TailscaleModule(decman.Module):
    """Tailscaled service + firewall-mode override.

    The `tailscale` package itself is in SecurityModule. Putting it
    there alone leaves the daemon disabled — this module enables it
    and pins it to nftables (matching `modules/tailscale/tailscale.nix`).
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
        }
