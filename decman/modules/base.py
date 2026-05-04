import decman
from decman.plugins import pacman, aur

class BaseModule(decman.Module):

    def __init__(self):
        # I'll intend this module to be a singleton (only one instance ever),
        # so I'll inline the module name
        super().__init__("base")

    @pacman.packages
    def pkgs(self) -> set[str]:
        # Universal baseline only. Kernel/firmware/EFI/filesystem tools
        # live in host_kernel, host_disks — WSL roles can't include those.
        return {
            "base",
            "base-devel",
            "git",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"decman"}
