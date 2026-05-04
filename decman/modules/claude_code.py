import decman
from decman.plugins import pacman, aur


class ClaudeCodeModule(decman.Module):
    """Sandbox runtime support for claude-code.

    `claude-code` itself isn't packaged here — install via the
    official npm/installer or a CustomPackage(pkgbuild_directory=...)
    pointing at a local PKGBUILD. claude-code-seccomp ships the
    apply-seccomp helper and BPF blob that sandbox.seccomp.bpfPath
    in ~/.claude/settings.json points at — installs to:
      ~/.local/share/claude-code/seccomp/x64/apply-seccomp
      ~/.local/share/claude-code/seccomp/x64/seccomp-unix-block.bpf
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
