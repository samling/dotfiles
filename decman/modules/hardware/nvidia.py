import decman
from decman.plugins import pacman


class NvidiaModule(decman.Module):
    """Nvidia userspace.

    Kernel modules are NOT declared here - they belong with the kernel
    package. On CachyOS that's `linux-cachyos-nvidia-open` /
    `linux-cachyos-lts-nvidia-open` (precompiled against the matching
    kernel, declared by `CachyOSModule`). Ada declares
    `nvidia-open-dkms` in its host configuration for stock Arch kernels
    and its Turing-or-newer GPU.

    include_32bit defaults to True for existing gaming hosts. Work-only
    hosts can omit the Steam/Wine compatibility libraries without losing
    native graphics, OpenCL, video acceleration or hardware utilities.

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
            packages |= {
                # 32-bit userspace for steam / wine / lutris.
                "lib32-nvidia-utils",
                "lib32-opencl-nvidia",
                "lib32-vulkan-icd-loader",
            }
        return packages
