import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from modules.hardware import zenbook


class Store(dict):
    def ensure(self, key, default):
        self.setdefault(key, default)


def test_zenbook_disables_wakeup_for_logitech_lightspeed_receiver():
    rule = zenbook.ZenbookModule().files()[
        "/etc/udev/rules.d/90-logitech-lightspeed-no-wakeup.rules"
    ]

    assert rule.content == (
        'ACTION=="add|change", SUBSYSTEM=="usb", '
        'ATTR{idVendor}=="046d", ATTR{idProduct}=="c539", '
        'TEST=="power/wakeup", ATTR{power/wakeup}="disabled"\n'
    )


def test_zenbook_reloads_and_triggers_udev_on_change(monkeypatch):
    calls = []
    module = zenbook.ZenbookModule()
    store = Store(initrd_inputs_hash="unchanged")

    monkeypatch.setattr(zenbook.os, "makedirs", lambda *args, **kwargs: None)
    monkeypatch.setattr(zenbook, "reconcile_units", lambda *args: None)
    monkeypatch.setattr(
        zenbook.ZenbookModule,
        "_initrd_inputs_hash",
        lambda self: "unchanged",
    )
    monkeypatch.setattr(
        zenbook.decman,
        "prg",
        lambda cmd, **kwargs: calls.append((cmd, kwargs)),
    )

    module.on_change(store)

    assert calls == [
        (
            [
                "systemctl",
                "disable",
                "--now",
                "power-profiles-daemon.service",
            ],
            {"check": True},
        ),
        (
            ["systemctl", "mask", "power-profiles-daemon.service"],
            {"check": True},
        ),
        (["udevadm", "control", "--reload-rules"], {"check": True}),
        (
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
