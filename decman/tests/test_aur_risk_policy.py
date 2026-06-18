import sys
from pathlib import Path

import pytest


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from modules._aur_risk_policy import (
    AurMetadata,
    AurRiskPolicyError,
    evaluate_package_risks,
    fetch_aur_metadata,
)


class Store(dict):
    def ensure(self, key, default):
        self.setdefault(key, default)


def test_evaluate_package_risks_seeds_first_seen_maintainer_without_prompting():
    store = Store()
    prompts = []

    evaluate_package_risks(
        {"spotify"},
        store,
        metadata_by_package={
            "spotify": AurMetadata(
                name="spotify",
                package_base="spotify",
                maintainer="alice",
                last_modified=1_000,
            )
        },
        now=2_000,
        recent_window_seconds=100,
        confirm=lambda msg, default=False: prompts.append((msg, default)) or True,
    )

    assert store["aur_known_maintainers"] == {"spotify": "alice"}
    assert prompts == []


def test_evaluate_package_risks_requires_confirmation_for_recently_modified_package():
    store = Store()
    prompts = []

    evaluate_package_risks(
        {"spotify"},
        store,
        metadata_by_package={
            "spotify": AurMetadata(
                name="spotify",
                package_base="spotify",
                maintainer="alice",
                last_modified=1_950,
            )
        },
        now=2_000,
        recent_window_seconds=100,
        confirm=lambda msg, default=False: prompts.append((msg, default)) or True,
    )

    assert prompts == [("Continue building risky AUR package(s)?", False)]
    assert store["aur_known_maintainers"] == {"spotify": "alice"}


def test_evaluate_package_risks_describes_recent_modification_window(monkeypatch):
    store = Store()
    warnings = []
    lists = []

    monkeypatch.setattr(
        "modules._aur_risk_policy.output.print_warning",
        lambda msg: warnings.append(msg),
    )
    monkeypatch.setattr(
        "modules._aur_risk_policy.output.print_list",
        lambda msg, items, **kwargs: lists.append((msg, items, kwargs)),
    )

    evaluate_package_risks(
        {"spotify"},
        store,
        metadata_by_package={
            "spotify": AurMetadata(
                name="spotify",
                package_base="spotify",
                maintainer="alice",
                last_modified=1_950,
            )
        },
        now=2_000,
        recent_window_seconds=3 * 24 * 60 * 60,
        confirm=lambda msg, default=False: True,
    )

    assert warnings == [
        "AUR package risk policy flagged package(s). Recent AUR changes are "
        "not automatically bad, but they deserve PKGBUILD review before build "
        "because compromised or transferred packages often change shortly "
        "before abuse."
    ]
    assert lists == [
        (
            "AUR risk details:",
            ["spotify: modified 50 seconds ago (inside 3 days review window)"],
            {"elements_per_line": 1},
        )
    ]


def test_evaluate_package_risks_blocks_recently_modified_package_when_declined():
    store = Store()

    with pytest.raises(AurRiskPolicyError):
        evaluate_package_risks(
            {"spotify"},
            store,
            metadata_by_package={
                "spotify": AurMetadata(
                    name="spotify",
                    package_base="spotify",
                    maintainer="alice",
                    last_modified=1_950,
                )
            },
            now=2_000,
            recent_window_seconds=100,
            confirm=lambda msg, default=False: False,
        )

    assert store["aur_known_maintainers"] == {}


def test_evaluate_package_risks_warns_on_maintainer_change_and_updates_after_confirm():
    store = Store({"aur_known_maintainers": {"spotify": "alice"}})

    evaluate_package_risks(
        {"spotify"},
        store,
        metadata_by_package={
            "spotify": AurMetadata(
                name="spotify",
                package_base="spotify",
                maintainer="bob",
                last_modified=1_000,
            )
        },
        now=2_000,
        recent_window_seconds=100,
        confirm=lambda msg, default=False: True,
    )

    assert store["aur_known_maintainers"] == {"spotify": "bob"}


def test_evaluate_package_risks_keeps_old_maintainer_when_change_declined():
    store = Store({"aur_known_maintainers": {"spotify": "alice"}})

    with pytest.raises(AurRiskPolicyError):
        evaluate_package_risks(
            {"spotify"},
            store,
            metadata_by_package={
                "spotify": AurMetadata(
                    name="spotify",
                    package_base="spotify",
                    maintainer="bob",
                    last_modified=1_000,
                )
            },
            now=2_000,
            recent_window_seconds=100,
            confirm=lambda msg, default=False: False,
        )

    assert store["aur_known_maintainers"] == {"spotify": "alice"}


def test_evaluate_package_risks_warns_when_package_becomes_orphaned():
    store = Store({"aur_known_maintainers": {"spotify": "alice"}})
    prompts = []

    evaluate_package_risks(
        {"spotify"},
        store,
        metadata_by_package={
            "spotify": AurMetadata(
                name="spotify",
                package_base="spotify",
                maintainer=None,
                last_modified=1_000,
            )
        },
        now=2_000,
        recent_window_seconds=100,
        confirm=lambda msg, default=False: prompts.append((msg, default)) or True,
    )

    assert prompts == [("Continue building risky AUR package(s)?", False)]
    assert store["aur_known_maintainers"] == {"spotify": None}


def test_fetch_aur_metadata_indexes_results_by_name_and_package_base(monkeypatch):
    class Response:
        def json(self):
            return {
                "type": "multiinfo",
                "results": [
                    {
                        "Name": "split-pkg-bin",
                        "PackageBase": "split-pkg",
                        "Maintainer": "alice",
                        "LastModified": 1_000,
                    }
                ],
            }

    monkeypatch.setattr(
        "modules._aur_risk_policy.requests.get",
        lambda url, timeout: Response(),
    )

    metadata = fetch_aur_metadata({"split-pkg"})

    assert metadata["split-pkg-bin"] == metadata["split-pkg"]


def test_fetch_aur_metadata_raises_policy_error_on_request_failure(monkeypatch):
    def fail(url, timeout):
        raise RuntimeError("network unavailable")

    monkeypatch.setattr("modules._aur_risk_policy.requests.get", fail)

    with pytest.raises(AurRiskPolicyError):
        fetch_aur_metadata({"spotify"})
