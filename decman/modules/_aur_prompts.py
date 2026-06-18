"""Tune decman's AUR review/build prompts.

decman fires two prompts per AUR package on every run:
  - "Review PKGBUILD or show diff for X?" (default Y)
  - "Build this package?"                  (default Y)

PKGBUILD review/diff remains available, but defaults to no so enter can skip
packages after the risk-policy gate. The final build confirmation remains
interactive.

Call `install()` once from source.py before any decman run.
"""

from decman.core import output


def install() -> None:
    original = output.prompt_confirm

    def patched(msg: str, default=None) -> bool:
        if msg.startswith("Review PKGBUILD or show diff for "):
            return original(msg, default=False)
        return original(msg, default)

    output.prompt_confirm = patched
