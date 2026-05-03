import decman
from decman.plugins import pacman


class SystemModule(decman.Module):

    def __init__(self):
        super().__init__("system")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "amd-ucode",
            "b43-fwcutter",
            "cryptsetup",
            "device-mapper",
            "dialog",
            "diffutils",
            "dmidecode",
            "dmraid",
            "dracut",
            "e2fsprogs",
            "ex-vi-compat",
            "exfatprogs",
            "f2fs-tools",
            "haveged",
            "hdparm",
            "hwdetect",
            "hwinfo",
            "inetutils",
            "jfsutils",
            "kernel-install-for-dracut",
            "less",
            "logrotate",
            "lsb-release",
            "lsscsi",
            "lvm2",
            "man-db",
            "man-pages",
            "mdadm",
            "mtools",
            "nano",
            "nano-syntax-highlighting",
            "nilfs-utils",
            "ntfs-3g",
            "openssh",
            "perl",
            "sg3_utils",
            "smartmontools",
            "socat",
            "sof-firmware",
            "sudo",
            "sysfsutils",
            "systemd-sysvcompat",
            "texinfo",
            "usb_modeswitch",
            "usbutils",
            "which",
            "wireless-regdb",
            "xfsprogs",
        }
