"""PacmanCommands overrides used from source.py.

decman.pacman.commands holds the list of argv tuples it shells out
for each pacman action (install/remove/upgrade/etc). Subclassing
lets us swap in a no-op upgrade when we want to avoid pulling in
deps for AUR packages that are about to be removed (e.g. cuda
chasing llama.cpp-cuda's removal in the same run).
"""

from decman.plugins.pacman import PacmanCommands


class NoUpgrade(PacmanCommands):
    """Skip pacman -Syu but otherwise behave normally.

    Intended for ad-hoc applies where you've added or removed
    packages and don't want a full system upgrade in the same run.
    Use sparingly; the system still needs upgrades.
    """

    def upgrade(self) -> list[str]:
        return ["true"]
