import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class NetworkingModule(decman.Module):

    def __init__(self):
        super().__init__("networking")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "bind",
            "dnsmasq",
            "ethtool",
            "firewall-applet",
            "firewalld",
            "iwd",
            "modemmanager",
            "netctl",
            "networkmanager",
            "network-manager-applet",
            "networkmanager-openconnect",
            "networkmanager-openvpn",
            "nfs-utils",
            "nftables",
            "nss-mdns",
            "ntp",
            "xl2tpd",
        }

    @systemd.units
    def units(self) -> set[str]:
        return {
            "NetworkManager.service",
            "firewalld.service",
            "sshd.service",
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
