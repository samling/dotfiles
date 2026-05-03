import decman
from decman.plugins import pacman


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
            "iptables",
            "iwd",
            "modemmanager",
            "netctl",
            "networkmanager",
            "networkmanager-openconnect",
            "networkmanager-openvpn",
            "nfs-utils",
            "nss-mdns",
            "ntp",
            "xl2tpd",
        }
