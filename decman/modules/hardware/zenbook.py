import hashlib
import os

import decman
from decman.plugins import pacman, aur, systemd

from modules._systemd import reconcile_units


class ZenbookModule(decman.Module):
    """Asus Zenbook UM5606 (Ryzen AI / Radeon 880M) host-specific bits.

    Belongs in hosts/xen.py only — don't pull into the generic laptop
    role. Other laptops won't have asus-wmi, won't want asusd, and
    have their own EDID quirks (or none).

    The kernel cmdline param `drm.edid_firmware=eDP-1:edid/edid_mclk_fix.bin`
    is NOT managed here. It belongs in /etc/kernel/cmdline alongside
    root=, rw, etc., which decman has no opinion on. Edit it once by
    hand; subsequent decman runs rebuild the initrd to keep the
    embedded firmware fresh.

    on_change reinstalls kernels (re-running dracut) when the EDID
    blob or the dracut drop-in changes — gated by a content hash so
    unrelated edits don't pay the 30s+ rebuild cost.
    """

    _EDID_BLOB_PATH = "../etc/firmware/edid/edid_mclk_fix.bin"
    _DRACUT_CONF = (
        'install_items+=" /usr/lib/firmware/edid/edid_mclk_fix.bin "\n'
    )

    def __init__(self):
        super().__init__("zenbook")

    @pacman.packages
    def pacmanpkgs(self) -> set[str]:
        return {
            "amdgpu_top",
            "lact",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "asus-5606-fan-state-git",
            "asus-5606-firmware-check-git",
            "asusctl",
            "rog-control-center",
        }

    @systemd.units
    def units(self) -> set[str]:
        return {
            "asusd.service",
            "lactd.service",
        }

    def _initrd_inputs_hash(self) -> str:
        h = hashlib.sha256()
        with open(self._EDID_BLOB_PATH, "rb") as f:
            h.update(f.read())
        h.update(self._DRACUT_CONF.encode())
        return h.hexdigest()

    def on_change(self, store):
        # asusd.service has ReadWritePaths=/etc/asusd/; namespace setup
        # fails (status=226/NAMESPACE) if the dir is missing, and the
        # asusctl package doesn't ship it.
        os.makedirs("/etc/asusd", mode=0o755, exist_ok=True)

        reconcile_units(self, store)

        # Rebuild initrds (and re-emit boot entries) only when the EDID
        # blob or the dracut drop-in actually changed. reinstall-kernels
        # iterates every installed kernel and is slow.
        store.ensure("initrd_inputs_hash", "")
        current = self._initrd_inputs_hash()
        if store["initrd_inputs_hash"] != current:
            decman.prg(["reinstall-kernels"], check=False)
            store["initrd_inputs_hash"] = current

    def files(self) -> dict[str, decman.File]:
        return {
            # NOPASSWD sudo for the asus-5606-fan-state CLI.
            "/etc/sudoers.d/asus": decman.File(
                source_file="../etc/sudoers.d/asus",
                permissions=0o440,
                owner="root",
                group="root",
            ),
            # asus_wmi: don't toggle Fn-lock on at boot.
            "/etc/modprobe.d/asus.conf": decman.File(
                content="options asus_wmi fnlock_default=N\n",
                permissions=0o644,
                owner="root",
                group="root",
            ),
            # Extended-vblank EDID lets MCLK/FCLK downclock at 120Hz idle
            # on the UM5606's eDP-1 panel. See
            # https://wiki.archlinux.org/title/ASUS_Zenbook_UM5606
            "/usr/lib/firmware/edid/edid_mclk_fix.bin": decman.File(
                source_file=self._EDID_BLOB_PATH,
                bin_file=True,
                permissions=0o644,
                owner="root",
                group="root",
            ),
            # Embed the EDID firmware in the initrd so DRM picks it up
            # before the userspace firmware loader is reachable.
            "/etc/dracut.conf.d/zenbook-edid.conf": decman.File(
                content=self._DRACUT_CONF,
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }
