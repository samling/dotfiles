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


class IgnoreUpgradePackages:
    """Add pacman upgrade ignores while preserving all other commands."""

    def __init__(self, commands: PacmanCommands, packages: set[str]):
        self._commands = commands
        self._packages = packages

    def __getattr__(self, name):
        return getattr(self._commands, name)

    def upgrade(self) -> list[str]:
        command = self._commands.upgrade()
        if command == ["true"] or not self._packages:
            return command
        return [*command, "--ignore", ",".join(sorted(self._packages))]
