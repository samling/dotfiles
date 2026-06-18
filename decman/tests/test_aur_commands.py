import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from modules._aur_commands import SemiUnattended


def test_git_diff_shows_latest_pkgbuild_commit_patch():
    assert SemiUnattended().git_diff("abc123") == [
        "git",
        "show",
        "--oneline",
        "--patch",
        "HEAD",
        "--",
        "PKGBUILD",
        ".SRCINFO",
    ]
