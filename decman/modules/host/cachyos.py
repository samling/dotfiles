import decman
from decman.plugins import pacman


class CachyOSModule(decman.Module):
    """Everything CachyOS-shipped that titan should keep on first
    decman apply.

    Mixes three roughly distinct concerns into one module because
    they're all "things the CachyOS installer chose to lay down and
    we don't want decman to remove":

    1. Distro plumbing (cachyos-keyring, mirrorlists, hooks, settings,
       chwd). Required for the [cachyos] repos to keep working and
       for kernel/driver updates to flow.

    2. Kernel + bootloader. Replaces `ArchKernelModule` on this host:
       linux-cachyos / linux-cachyos-lts (plus their nvidia-open
       precompiled module variants), booted by limine via
       limine-mkinitcpio-hook, splash via plymouth + the CachyOS
       plymouth theme. Initramfs builder comes from `MkinitcpioModule`
       (vanilla Arch default, kept by titan). Titan filters
       `ArchKernelModule` out of its module list (see `hosts/titan.py`),
       so the `linux` / `linux-lts` packages aren't installed alongside
       `linux-cachyos*`.

    3. Installer-shipped extras we're not actively using but want
       decman to leave in place (alacritty, micro, ufw, vlc-plugins,
       fsarchiver, ...). These are stock-Arch packages, not
       CachyOS-specific, but they came with the ISO and pruning them
       is a separate decision from "stage titan under decman."
       Anything in this group can be lifted into a proper module
       (BluetoothModule, FontsModule, ...) later when it earns its
       way in.

    Paired with `NvidiaModule` for the nvidia userspace and
    `KernelModule` for firmware/microcode/zram - this module does not
    duplicate those.
    """

    def __init__(self):
        super().__init__("host_cachyos")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            # CachyOS repo plumbing. cachyos-rate-mirrors is the
            # rate-mirrors front-end shipped in the cachyos repo;
            # cachyos-hooks ships extra pacman hooks (chwd, plymouth
            # rebuild, etc.).
            "cachyos-hooks",
            "cachyos-keyring",
            "cachyos-mirrorlist",
            "cachyos-rate-mirrors",
            "cachyos-settings",
            "cachyos-v3-mirrorlist",
            "cachyos-v4-mirrorlist",
            "chwd",
            "cpupower",

            # CachyOS kernel stack. nvidia-open kernel modules are
            # precompiled against the matching cachyos kernel, so no
            # DKMS rebuild on kernel updates.
            "linux-cachyos",
            "linux-cachyos-headers",
            "linux-cachyos-lts",
            "linux-cachyos-lts-headers",
            "linux-cachyos-lts-nvidia-open",
            "linux-cachyos-nvidia-open",

            # Bootloader. limine-mkinitcpio-hook regenerates
            # /boot/limine entries when the kernel package's
            # mkinitcpio hook runs. The mkinitcpio package itself
            # comes from MkinitcpioModule (vanilla Arch / CachyOS
            # default).
            "limine",
            "limine-mkinitcpio-hook",
            "os-prober",

            # Boot splash.
            "cachyos-plymouth-bootanimation",
            "cachyos-plymouth-theme",
            "plymouth",

            # GUI for switching cachyos kernels. Optional convenience.
            "cachyos-kernel-manager",

            # Bluetooth extras the installer shipped. bluez-hid2hci is
            # the proprietary-HID switching tool some BT dongles need;
            # bluez-obex enables OBEX object push.
            "bluez-hid2hci",
            "bluez-obex",

            # Installer-shipped that we don't actively use but keep so
            # decman doesn't yank them on first apply. Cull case-by-case
            # later.
            "alacritty",
            "awesome-terminal-fonts",
            "cachyos-fish-config",
            "cachyos-hello",
            "cachyos-micro-settings",
            "cachyos-packageinstaller",
            "cachyos-wallpapers",
            "cachyos-zsh-config",
            "fsarchiver",
            "lib32-vulkan-radeon",
            "micro",
            "pv",
            "shelly",
            "ttf-meslo-nerd",
            "ufw",
            "ufw-extras",
            "vlc-plugins-all",
            "xf86-video-amdgpu",
        }
