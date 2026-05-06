import decman
from decman.plugins import pacman


class DisksModule(decman.Module):
    """Filesystem tools, RAID, LVM, encryption, EFI boot.

    Hardware-host concerns. WSL roles should omit — WSL has no
    block devices to format, no /boot/EFI, no RAID.
    """

    def __init__(self):
        super().__init__("host_disks")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "btrfs-progs",
            "cryptsetup",
            "device-mapper",
            "dmraid",
            "dosfstools",
            "e2fsprogs",
            "efibootmgr",
            "efitools",
            "exfatprogs",
            "f2fs-tools",
            "hdparm",
            "jfsutils",
            "lvm2",
            "mdadm",
            "nilfs-utils",
            "ntfs-3g",
            "sg3_utils",
            "smartmontools",
            "xfsprogs",
        }
