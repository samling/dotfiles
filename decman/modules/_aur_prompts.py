"""Auto-answer decman's per-package AUR review/build prompts.

decman fires two prompts per AUR package on every run:
  - "Review PKGBUILD or show diff for X?" (default Y)
  - "Build this package?"                  (default Y)

There's no config flag to skip these (verified against decman 1.x), so
we monkey-patch `output.prompt_confirm`. Only the per-package prompts
are answered automatically; everything else (top-level "Proceed?",
"Remember this choice?", the install/upgrade/remove summary) still
prompts the user, so there's no risk of an unattended decman silently
making large changes.

Call `install()` once from source.py before any decman run.
"""

from decman.core import output


def install() -> None:
    original = output.prompt_confirm

    def patched(msg: str, default=None) -> bool:
        if msg.startswith("Review PKGBUILD or show diff for "):
            return False
        if msg == "Build this package?":
            return True
        return original(msg, default)

    output.prompt_confirm = patched
