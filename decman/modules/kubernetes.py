import decman
from decman.plugins import pacman, aur


class KubernetesModule(decman.Module):
    """K8s CLI tooling. Mirrors `modules/common/kubernetes.nix`."""

    def __init__(self):
        super().__init__("kubernetes")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "helm",
            "k9s",
            "krew",
            "kubectl",
            "kubectx",
            "talhelper",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "kubecolor",
            "talosctl-bin",
        }
