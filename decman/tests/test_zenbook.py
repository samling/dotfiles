import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from modules.hardware import zenbook


class Store(dict):
    def ensure(self, key, default):
        self.setdefault(key, default)


def test_zenbook_masks_power_profiles_daemon():
    assert zenbook.ZenbookModule().symlinks() == {
        "/etc/systemd/system/power-profiles-daemon.service": "/dev/null",
    }


def test_zenbook_disables_wakeup_for_logitech_lightspeed_receiver():
    rule = zenbook.ZenbookModule().files()[
        "/etc/udev/rules.d/90-logitech-lightspeed-no-wakeup.rules"
    ]

    assert rule.content == (
        'ACTION=="add|change", SUBSYSTEM=="usb", '
        'ATTR{idVendor}=="046d", ATTR{idProduct}=="c539", '
        'TEST=="power/wakeup", ATTR{power/wakeup}="disabled"\n'
    )


def test_zenbook_stops_ppd_before_reconciling_and_reloads_udev(monkeypatch):
    events = []
    module = zenbook.ZenbookModule()
    store = Store(initrd_inputs_hash="unchanged")

    monkeypatch.setattr(zenbook.os, "makedirs", lambda *args, **kwargs: None)
    monkeypatch.setattr(
        zenbook,
        "reconcile_units",
        lambda module, store: events.append(("reconcile_units", module, store)),
    )
    monkeypatch.setattr(
        zenbook.ZenbookModule,
        "_initrd_inputs_hash",
        lambda self: "unchanged",
    )
    monkeypatch.setattr(
        zenbook.decman,
        "prg",
        lambda cmd, **kwargs: events.append(("prg", cmd, kwargs)),
    )

    module.on_change(store)

    assert events == [
        (
            "prg",
            [
                "systemctl",
                "disable",
                "--now",
                "power-profiles-daemon.service",
            ],
            {"check": True},
        ),
        ("reconcile_units", module, store),
        (
            "prg",
            ["udevadm", "control", "--reload-rules"],
            {"check": True},
        ),
        (
            "prg",
            [
                "udevadm",
                "trigger",
                "--action=change",
                "--subsystem-match=usb",
                "--attr-match=idVendor=046d",
                "--attr-match=idProduct=c539",
            ],
            {"check": True},
        ),
    ]
