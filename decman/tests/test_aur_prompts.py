import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from modules import _aur_prompts


def test_install_defaults_pkgbuild_review_prompt_to_no(monkeypatch):
    calls = []

    def original(msg, default=None):
        calls.append((msg, default))
        return False

    monkeypatch.setattr(_aur_prompts.output, "prompt_confirm", original)

    _aur_prompts.install()

    assert _aur_prompts.output.prompt_confirm(
        "Review PKGBUILD or show diff for spotify?", default=True
    ) is False
    assert calls == [("Review PKGBUILD or show diff for spotify?", False)]


def test_install_delegates_build_prompt(monkeypatch):
    calls = []

    def original(msg, default=None):
        calls.append((msg, default))
        return False

    monkeypatch.setattr(_aur_prompts.output, "prompt_confirm", original)

    _aur_prompts.install()

    assert _aur_prompts.output.prompt_confirm("Build this package?", default=True) is False
    assert calls == [("Build this package?", True)]
