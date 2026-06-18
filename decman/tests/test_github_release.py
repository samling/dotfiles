import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from plugins import github_release
from plugins.github_release import (
    GithubCommands,
    GithubInterface,
    GithubPackage,
    GithubReleaseInfo,
)


def test_github_package_accepts_optional_asset_pattern():
    pkg = GithubPackage("cli/cli", pattern="*linux_amd64*")

    assert pkg.repo == "cli/cli"
    assert pkg.pattern == "*linux_amd64*"


def test_list_releases_command_omits_limit_by_default():
    cmd = GithubCommands().list_releases(GithubPackage("cli/cli"), as_user=False)

    assert cmd == [
        "gh",
        "release",
        "list",
        "--repo",
        "cli/cli",
        "--json",
        "name,tagName,isLatest,publishedAt",
    ]


def test_list_releases_command_limits_to_latest_when_requested():
    cmd = GithubCommands().list_releases(
        GithubPackage("cli/cli"), as_user=False, latest_only=True
    )

    assert cmd == [
        "gh",
        "release",
        "list",
        "--repo",
        "cli/cli",
        "--json",
        "name,tagName,isLatest,publishedAt",
        "--limit",
        "1",
    ]


def test_release_assets_command_outputs_json():
    cmd = GithubCommands().release_assets(
        GithubPackage("cli/cli"), tag="v2.95.0", as_user=False
    )

    assert cmd == [
        "gh",
        "release",
        "view",
        "v2.95.0",
        "--repo",
        "cli/cli",
        "--json",
        "assets",
    ]


def test_list_releases_accepts_plain_repo_strings(monkeypatch):
    calls = []

    def run(cmd, user=None, mimic_login=False):
        calls.append((cmd, user, mimic_login))
        return (
            0,
            "["
            '{"name":"GitHub CLI 2.94.0","tagName":"v2.94.0",'
            '"isLatest":false,"publishedAt":"2026-06-10T21:47:49Z"},'
            '{"name":"GitHub CLI 2.95.0","tagName":"v2.95.0",'
            '"isLatest":true,"publishedAt":"2026-06-17T19:55:07Z"}'
            "]",
        )

    monkeypatch.setattr(github_release.command, "run", run)

    releases = GithubInterface(GithubCommands()).list_releases({"cli/cli"})

    assert releases == {
        GithubReleaseInfo(
            name="GitHub CLI 2.94.0",
            tag_name="v2.94.0",
            is_latest=False,
            published_at="2026-06-10T21:47:49Z",
        ),
        GithubReleaseInfo(
            name="GitHub CLI 2.95.0",
            tag_name="v2.95.0",
            is_latest=True,
            published_at="2026-06-17T19:55:07Z",
        ),
    }
    assert calls == [
        (
            [
                "gh",
                "release",
                "list",
                "--repo",
                "cli/cli",
                "--json",
                "name,tagName,isLatest,publishedAt",
            ],
            None,
            False,
        ),
    ]


def test_list_releases_passes_latest_only_to_command(monkeypatch):
    calls = []

    def run(cmd, user=None, mimic_login=False):
        calls.append((cmd, user, mimic_login))
        return (
            0,
            "["
            '{"name":"GitHub CLI 2.95.0","tagName":"v2.95.0",'
            '"isLatest":true,"publishedAt":"2026-06-17T19:55:07Z"}'
            "]",
        )

    monkeypatch.setattr(github_release.command, "run", run)

    releases = GithubInterface(GithubCommands()).list_releases({"cli/cli"}, latest_only=True)

    assert releases == {
        GithubReleaseInfo(
            name="GitHub CLI 2.95.0",
            tag_name="v2.95.0",
            is_latest=True,
            published_at="2026-06-17T19:55:07Z",
        )
    }
    assert calls == [
        (
            [
                "gh",
                "release",
                "list",
                "--repo",
                "cli/cli",
                "--json",
                "name,tagName,isLatest,publishedAt",
                "--limit",
                "1",
            ],
            None,
            False,
        ),
    ]


def test_list_releases_filters_by_release_asset_pattern(monkeypatch):
    def run(cmd, user=None, mimic_login=False):
        if cmd[:3] == ["gh", "release", "list"]:
            return (
                0,
                "["
                '{"name":"GitHub CLI 2.94.0","tagName":"v2.94.0",'
                '"isLatest":false,"publishedAt":"2026-06-10T21:47:49Z"},'
                '{"name":"GitHub CLI 2.95.0","tagName":"v2.95.0",'
                '"isLatest":true,"publishedAt":"2026-06-17T19:55:07Z"}'
                "]",
            )

        tag = cmd[3]
        if tag == "v2.94.0":
            return (0, '{"assets":[{"name":"gh_2.94.0_linux_arm64.tar.gz"}]}')
        if tag == "v2.95.0":
            return (0, '{"assets":[{"name":"gh_2.95.0_linux_amd64.tar.gz"}]}')
        raise AssertionError(f"unexpected command: {cmd}")

    monkeypatch.setattr(github_release.command, "run", run)

    releases = GithubInterface(GithubCommands()).list_releases(
        {GithubPackage("cli/cli", pattern="*linux_amd64*")}
    )

    assert releases == {
        GithubReleaseInfo(
            name="GitHub CLI 2.95.0",
            tag_name="v2.95.0",
            is_latest=True,
            published_at="2026-06-17T19:55:07Z",
        )
    }
