"""Skip per-package AUR prompts, retaining Decman's batch confirmation.

ForeignPackageManager.install lists the complete batch and asks "Proceed?"
before creating its build environment. Upgrade and new-install batches may
be separate. Pacman transaction prompts and all unrelated prompts remain.
"""

from functools import wraps

from decman.core import output


def install() -> None:
    original = output.prompt_confirm
    if getattr(original, "__aur_batch_prompts__", False):
        return

    @wraps(original)
    def patched(msg: str, default=None) -> bool:
        if msg.startswith("Review PKGBUILD or show diff for "):
            return False
        if msg == "Build this package?":
            return True
        return original(msg, default)

    setattr(patched, "__aur_batch_prompts__", True)
    output.prompt_confirm = patched
