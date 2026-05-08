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
- AurKeysModule: which validpgpkeys-using AUR packages a role
  installs (spotify, wlogout, ...) is role-specific, so the
  per-package fetch_*() calls live in the role file. (Both roles
  build AUR packages; only signature-verified ones need this.)
- LocaleModule: trivially identical, but each role places it
  immediately after UsersModule (and after _aur_keys() on laptop)
  before the bulk of modules register, so it stays in the role file
  to keep that ordering visible.
"""
from modules.ai_tools import AIToolsModule
from modules.archlinux import ArchlinuxModule
from modules.base import BaseModule
from modules.claude_code import ClaudeCodeModule
from modules.codex import CodexModule
from modules.core import CoreModule
from modules.data import DataModule
from modules.dev import DevModule
from modules.docker import DockerModule
from modules.editors import EditorsModule
from modules.git import GitModule
from modules.kubernetes import KubernetesModule
from modules.media import MediaModule
from modules.networking import NetworkingModule
from modules.security import SecurityModule
from modules.shell import ShellModule
from modules.system import SystemModule
from modules.virtualization import VirtualizationModule

MODULES = [
    AIToolsModule(),
    ArchlinuxModule(),
    BaseModule(),
    ClaudeCodeModule(),
    CodexModule(),
    CoreModule(),
    DataModule(),
    DevModule(),
    DockerModule(),
    EditorsModule(),
    GitModule(),
    KubernetesModule(),
    MediaModule(),
    NetworkingModule(),
    SecurityModule(),
    ShellModule(),
    SystemModule(),
    VirtualizationModule(),
]
