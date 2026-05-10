"""Modules wanted by every role we manage.

Roles compose this list with their own role-specific modules:

    from roles.common import MODULES as COMMON

    MODULES = [
        UsersModule(extra_groups=(...)),  # role-specific args
        LocaleModule(),                   # NB: kept out of COMMON
        *COMMON,
        ...role-specific modules...,
    ]

Deliberate exclusions:
- UsersModule: extra_groups/managed_groups vary per role.
- LocaleModule: trivially identical, but each role places it
  immediately after UsersModule before the bulk of modules
  register, so it stays in the role file to keep that ordering
  visible.

AurKeysModule lives in COMMON via `_aur_keys()` even though only
GUI roles consume the keys it imports (spotify, wlogout). The
per-host cost is two GPG entries in the aurbuilder keyring on
runs that don't actually build those packages — negligible — and
having one canonical list of validpgpkeys signers is worth more
than the saved keystrokes.
"""
from modules.common.ai_tools import AIToolsModule
from modules.common.archlinux import ArchlinuxModule
from modules.common.aur_keys import AurKeysModule
from modules.common.base import BaseModule
from modules.common.claude_code import ClaudeCodeModule
from modules.common.codex import CodexModule
from modules.common.core import CoreModule
from modules.common.data import DataModule
from modules.common.dev import DevModule
from modules.common.docker import DockerModule
from modules.common.editors import EditorsModule
from modules.common.filesystems import FilesystemsModule
from modules.common.git import GitModule
from modules.common.kubernetes import KubernetesModule
from modules.common.media import MediaModule
from modules.common.networking import NetworkingModule
from modules.common.security import SecurityModule
from modules.common.shell import ShellModule
from modules.common.system import SystemModule
from modules.common.virtualization import VirtualizationModule


def _aur_keys() -> AurKeysModule:
    """AurKeysModule preconfigured with every validpgpkeys signer
    any of our roles needs. Add new fetches here, not in role files.
    """
    keys = AurKeysModule()
    keys.fetch_spotify()
    keys.fetch_wlogout()
    return keys


MODULES = [
    AIToolsModule(),
    ArchlinuxModule(),
    _aur_keys(),
    BaseModule(),
    ClaudeCodeModule(),
    CodexModule(),
    CoreModule(),
    DataModule(),
    DevModule(),
    DockerModule(),
    EditorsModule(),
    FilesystemsModule(),
    GitModule(),
    KubernetesModule(),
    MediaModule(),
    NetworkingModule(),
    SecurityModule(),
    ShellModule(),
    SystemModule(),
    VirtualizationModule(),
]
