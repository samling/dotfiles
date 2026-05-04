import decman
from decman.plugins import pacman


class ClaudeCodeModule(decman.Module):
    """Sandbox runtime support for claude-code.

    `claude-code` itself isn't packaged here — install via the
    official npm/installer or a CustomPackage(pkgbuild_directory=...)
    pointing at a local PKGBUILD. The seccomp blob and apply-seccomp
    helper that the nix `claude-seccomp` derivation builds aren't
    captured either; if you rely on sandbox.seccomp.bpfPath in
    ~/.claude/settings.json those need to land at:
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
