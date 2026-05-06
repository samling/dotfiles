import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class HostNetworkingModule(decman.Module):
    """NetworkManager + WiFi/cellular daemons + host firewall + L2TP.

    Hardware-host networking. WSL2 inherits its network stack from
    Windows; per the nix WSL module this is force-disabled there
    (`networkmanager.enable = lib.mkForce false`). Generic CLI
    debugging tools (bind, dnsmasq, nmap, etc.) live in
    NetworkingModule and stay loaded on WSL.
    """

    def __init__(self):
        super().__init__("host_networking")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "firewall-applet",
            "firewalld",
            "iwd",
            "modemmanager",
            "netctl",
            "networkmanager",
            "network-manager-applet",
            "networkmanager-openconnect",
            "networkmanager-openvpn",
            "xl2tpd",
        }

    @systemd.units
    def units(self) -> set[str]:
        return {
            "NetworkManager.service",
            "firewalld.service",
        }

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        return {
            "sboynton": {
                "nm-applet.service",
            },
        }

    def on_change(self, store):
        reconcile_units(self, store)
