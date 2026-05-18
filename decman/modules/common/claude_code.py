import decman
from decman.plugins import pacman, aur, systemd

from modules._paths import PKGBUILDS as _PKGBUILDS
from modules._systemd import reconcile_units


class ClaudeCodeModule(decman.Module):
    """Sandbox runtime support for claude-code.

    `claude-code` itself isn't packaged here — install via the
    official npm/installer or a CustomPackage(pkgbuild_directory=...)
    pointing at a local PKGBUILD. claude-code-seccomp ships the
    apply-seccomp helper and BPF blob that sandbox.seccomp.bpfPath
    in ~/.claude/settings.json points at — installs to:
      ~/.local/share/claude-code/seccomp/x64/apply-seccomp
      ~/.local/share/claude-code/seccomp/x64/seccomp-unix-block.bpf

    agent-status-bin pulls the prebuilt binary from the upstream
    GitHub release; agent-status.service is the per-user collector
    the Claude Code hooks POST session events to.
    """

    def __init__(self):
        super().__init__("claude_code")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "bubblewrap",
            "libseccomp",
            "socat",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "claude-code-seccomp",
        }

    @aur.custom_packages
    def custompkgs(self) -> set[aur.CustomPackage]:
        return {
            aur.CustomPackage(
                pkgname="agent-status-bin",
                pkgbuild_directory=str(_PKGBUILDS / "agent-status-bin"),
            ),
        }

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        return {
            "sboynton": {
                "agent-status.service",
            },
        }

    def on_change(self, store):
        reconcile_units(self, store)
