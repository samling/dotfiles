import decman

from roles.wsl import MODULES

# Sam-Desktop: the Windows desktop running decman inside WSL2. Kept
# wired up after the bare-metal switch to titan in case we ever
# resurrect the WSL config (or stand up another Windows host).
#
# No kernel / initramfs / bootloader module registered here on
# purpose - WSL2 boots the Microsoft kernel, so the host's-pick-its-
# own-kernel-stack pattern that titan and xen follow has no
# counterpart on WSL. roles/wsl.py already omits the rest of host.*
# (disks, hardware, networking) for the same reason.
decman.modules += MODULES

# Per-host packages. Layered on top of role / module packages.
decman.pacman.packages |= set()
decman.aur.packages |= set()
