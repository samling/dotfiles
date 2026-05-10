import decman
from decman.plugins import pacman


class DisksModule(decman.Module):
    """RAID, LVM, encryption, EFI boot, SMART/SCSI tooling.

    Hardware-host concerns: every package here pokes at a real
    /dev tree, NVRAM, or physical disks. WSL2 roles must omit this
    module — there are no block devices to manage, no /boot/EFI,
    no RAID arrays.

    Generic filesystem userland (mkfs.*, fsck.*, ntfs-3g, etc.) used
    to live here too. It moved to `modules.common.filesystems` because
    the FS tools are useful even on hosts that don't manage their own
    disks (mounting disk images, working with USB sticks under WSL2's
    `wsl --mount`, etc.). Keeping the split lets a hypothetical
    headless or non-host role grab FS tools without pulling efitools
    or mdadm into its closure.
    """

    def __init__(self):
        super().__init__("host_disks")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "cryptsetup",
            "device-mapper",
            "dmraid",
            "efibootmgr",
            "efitools",
            "hdparm",
            "lvm2",
            "mdadm",
            "sg3_utils",
            "smartmontools",
        }
