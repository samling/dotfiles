import subprocess

import pytest

from check_declared_asdeps import (
    declared_package_names,
    find_declared_asdeps,
    run_preflight,
)


class CustomPackage:
    def __init__(self, pkgname):
        self.pkgname = pkgname


def test_declared_package_names_includes_native_aur_and_custom_packages():
    assert declared_package_names(
        pacman_packages={"git"},
        aur_packages={"spotify"},
        custom_packages={CustomPackage("command-snippets-bin")},
    ) == {"command-snippets-bin", "git", "spotify"}


def test_find_declared_asdeps_returns_declared_packages_marked_as_dependencies():
    assert find_declared_asdeps(
        declared={"git", "xembedsniproxy", "zsh"},
        dep_installed={"glibc", "xembedsniproxy", "zsh"},
    ) == ["xembedsniproxy", "zsh"]


def test_run_preflight_marks_declared_asdeps_explicit_when_confirmed(capsys):
    calls = []

    def confirm(prompt):
        calls.append(("confirm", prompt))
        return True

    def run(cmd):
        calls.append(("run", cmd))
        return subprocess.CompletedProcess(cmd, 0)

    rc = run_preflight(
        declared={"xembedsniproxy"},
        dep_installed={"xembedsniproxy"},
        dry_run=False,
        confirm=confirm,
        run=run,
    )

    assert rc == 0
    assert calls == [
        ("confirm", "Mark these packages explicit before running decman? [y/N] "),
        ("run", ["sudo", "pacman", "-D", "--asexplicit", "xembedsniproxy"]),
    ]
    assert "declared in decman but currently marked as dependencies" in capsys.readouterr().out


def test_run_preflight_fails_without_mutating_when_declined():
    def confirm(prompt):
        return False

    def run(cmd):
        raise AssertionError("pacman should not run when the prompt is declined")

    rc = run_preflight(
        declared={"xembedsniproxy"},
        dep_installed={"xembedsniproxy"},
        dry_run=False,
        confirm=confirm,
        run=run,
    )

    assert rc == 1


def test_run_preflight_dry_run_reports_without_mutating(capsys):
    def run(cmd):
        raise AssertionError("pacman should not run during dry-run preflight")

    rc = run_preflight(
        declared={"xembedsniproxy"},
        dep_installed={"xembedsniproxy"},
        dry_run=True,
        confirm=lambda prompt: True,
        run=run,
    )

    assert rc == 1
    assert "sudo pacman -D --asexplicit xembedsniproxy" in capsys.readouterr().out


def test_run_preflight_succeeds_quietly_when_nothing_needs_fixing(capsys):
    rc = run_preflight(
        declared={"git"},
        dep_installed={"glibc"},
        dry_run=False,
        confirm=lambda prompt: pytest.fail("should not prompt"),
        run=lambda cmd: pytest.fail("should not run pacman"),
    )

    assert rc == 0
    assert capsys.readouterr().out == ""
