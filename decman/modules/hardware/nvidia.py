import decman
from decman.plugins import pacman


class NvidiaModule(decman.Module):
    """Nvidia userspace.

    Kernel modules are NOT declared here - they belong with the kernel
    stack. Titan uses `nvidia-580xx-open-dkms` for both CachyOS kernels
    (declared by `CachyOSModule`). Ada declares `nvidia-open-dkms` in its
    host configuration for stock Arch kernels and its Turing-or-newer GPU.

    include_32bit defaults to True for existing gaming hosts. Work-only
    hosts can omit the Steam/Wine compatibility libraries without losing
    native graphics, OpenCL, video acceleration or hardware utilities.

    Pairs with whichever kernel stack the host uses. Host-scoped:
    register from `hosts/<name>.py`, not from a role, since GPU vendor
    is a per-machine fact.
    """

    def __init__(self, *, include_32bit: bool = True, legacy_580: bool = False):
        super().__init__("hardware_nvidia")
        self.include_32bit = include_32bit
        # Opt in per host; other machines retain the current driver branch.
        self.legacy_580 = legacy_580

    @pacman.packages
    def pkgs(self) -> set[str]:
        packages = {
            # 64-bit userspace.
            "cuda",
            "egl-wayland",
            "ggml-cuda",
            "libva-nvidia-driver",
            "llama-cpp",
            # "nvidia-settings",
            "nvidia-580xx-settings" if self.legacy_580 else "nvidia-settings",
            # "nvidia-utils",
            "nvidia-580xx-utils" if self.legacy_580 else "nvidia-utils",
            # "opencl-nvidia",
            "opencl-nvidia-580xx" if self.legacy_580 else "opencl-nvidia",
            "openrgb",
            "python-pytorch-cuda",
            "vulkan-icd-loader",
        }

        if self.include_32bit:
            # 32-bit userspace for steam / wine / lutris.
            packages |= {
                # "lib32-nvidia-utils",
                "lib32-nvidia-580xx-utils" if self.legacy_580 else "lib32-nvidia-utils",
                # "lib32-opencl-nvidia",
                "lib32-opencl-nvidia-580xx" if self.legacy_580 else "lib32-opencl-nvidia",
                "lib32-vulkan-icd-loader",
            }

        return packages
