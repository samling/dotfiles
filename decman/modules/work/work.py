import decman
from decman.plugins import pacman, aur


class WorkModule(decman.Module):
    """Work-only tools. Already-packaged: teleport-bin in pkgs/."""

    def __init__(self):
        super().__init__("work")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "aws-cli",
            "azure-cli",
            "certbot",
            "cilium-cli",
            "libfido2",
            "terraform",
            "terragrunt",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        # vault-bin tracks Hashicorp's official binary; nvault is
        # internal and not present in AUR — install separately if needed.
        return {
            "cursor-bin",
            "dcvviewer-bin",
            "globalprotect-openconnect-git",
            "slack-desktop",
            "teams-for-linux-bin",
            "teleport-bin",
            "vault-bin",
        }

    def files(self) -> dict[str, decman.File]:
        # Mirrors `home.sessionVariables.TELEPORT_TOOLS_VERSION = "off"`.
        # Putting it in /etc/environment makes the opt-out apply to GUI
        # launches and cron, not just login shells.
        return {
            "/etc/environment.d/50-teleport.conf": decman.File(
                content="TELEPORT_TOOLS_VERSION=off\n",
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }
