import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


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
            "lm_sensors",
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
            "zram-generator",
        }

    @systemd.units
    def units(self) -> set[str]:
        # systemd-oomd is enabled by default on most setups but listing
        # it here makes the dependency explicit. zram is generator-driven
        # (no service to enable).
        return {"systemd-oomd.service"}

    def on_change(self, store):
        reconcile_units(self, store)

    def files(self) -> dict[str, decman.File]:
        return {
            # zram swap. ram/2 is what NixOS' zramSwap.enable defaults
            # to; cap at 8G so a 64G workstation doesn't reserve 32G.
            "/etc/systemd/zram-generator.conf": decman.File(
                content=(
                    "[zram0]\n"
                    "zram-size = min(ram / 2, 8192)\n"
                    "compression-algorithm = zstd\n"
                ),
                permissions=0o644,
                owner="root",
                group="root",
            ),
            # Mirrors `systemd.oomd.enableUserSlices = true`.
            "/etc/systemd/system/user-.slice.d/50-oomd.conf": decman.File(
                content=(
                    "[Slice]\n"
                    "ManagedOOMSwap=auto\n"
                    "ManagedOOMMemoryPressure=kill\n"
                ),
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }
