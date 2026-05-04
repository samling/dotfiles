import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class NetworkingModule(decman.Module):
    """Generic networking CLI tools and protocols that make sense
    everywhere (bind, dnsmasq, nfs, mdns, sshd, scanners).

    NetworkManager + WiFi/cellular daemons + host firewall live in
    host_networking — WSL roles must omit that module since WSL2
    inherits its network stack from Windows.
    """

    def __init__(self):
        super().__init__("networking")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "arp-scan",
            "bind",
            "dnsmasq",
            "ethtool",
            "ipcalc",
            "nfs-utils",
            "nftables",
            "nmap",
            "nss-mdns",
            "ntp",
            "openbsd-netcat",
            "smbclient",
            "traceroute",
            "websocat",
        }

    @systemd.units
    def units(self) -> set[str]:
        return {
            "sshd.service",
        }

    def on_change(self, store):
        reconcile_units(self, store)
