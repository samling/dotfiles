import decman
from decman.plugins import pacman, aur

class BaseModule(decman.Module):

    def __init__(self):
        # I'll intend this module to be a singleton (only one instance ever),
        # so I'll inline the module name
        super().__init__("base")

    @pacman.packages
    def pkgs(self) -> set[str]:
        # Universal baseline only. Kernel/firmware live in
        # modules.host.kernel; block-device tooling (RAID/EFI/SMART)
        # in modules.host.disks — WSL roles omit both. Generic FS
        # userland (mkfs.*/fsck.*) lives in modules.common.filesystems
        # and ships everywhere.
        return {
            "base",
            "base-devel",
            "git",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"decman"}
