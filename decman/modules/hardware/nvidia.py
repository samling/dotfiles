import decman
from decman.plugins import pacman


class NvidiaModule(decman.Module):
    """Nvidia userspace.

    Kernel modules are NOT declared here - they belong with the kernel
    package. On CachyOS that's `linux-cachyos-nvidia-open` /
    `linux-cachyos-lts-nvidia-open` (precompiled against the matching
    kernel, declared by `CachyOSModule`). On stock-Arch hosts the
    kernel-module choice is `nvidia-open-dkms` and should sit in an
    arch-specific nvidia module if/when one exists.

    Pairs with whichever kernel stack the host uses. Host-scoped:
    register from `hosts/<name>.py`, not from a role, since GPU vendor
    is a per-machine fact.
    """

    def __init__(self, *, include_32bit: bool = True):
        super().__init__("hardware_nvidia")
        self.include_32bit = include_32bit

    @pacman.packages
    def pkgs(self) -> set[str]:
        packages = {
            # 64-bit userspace.
            "egl-wayland",
            "libva-nvidia-driver",
            "nvidia-settings",
            "nvidia-utils",
            "opencl-nvidia",
            "openrgb",
            "vulkan-icd-loader",
        }

        if self.include_32bit:
            # 32-bit userspace for steam / wine / lutris.
            packages |= {
                "lib32-nvidia-utils",
                "lib32-opencl-nvidia",
                "lib32-vulkan-icd-loader",
            }

        return packages
