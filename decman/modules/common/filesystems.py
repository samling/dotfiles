import decman
from decman.plugins import pacman


class FilesystemsModule(decman.Module):
    """Filesystem userland: mkfs.*, fsck.*, ntfs-3g.

    Useful on every host, including WSL2. WSL2 doesn't manage its own
    block devices, but `wsl --mount` exposes raw disks and disk images
    into the WSL2 namespace, where mkfs/fsck on btrfs/ext4/exfat/ntfs
    targets is the same as bare-metal.

    Block-device-only tooling (RAID, LVM, EFI, SMART, SCSI) lives in
    `modules.host.disks` and stays opt-in for non-WSL hosts.
    """

    def __init__(self):
        super().__init__("filesystems")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "btrfs-progs",
            "dosfstools",
            "e2fsprogs",
            "exfatprogs",
            "f2fs-tools",
            "jfsutils",
            "nilfs-utils",
            "ntfs-3g",
            "xfsprogs",
        }
