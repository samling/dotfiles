import decman
from decman.plugins import pacman, aur


class KubernetesModule(decman.Module):
    """K8s CLI tooling. Mirrors `modules/common/kubernetes.nix`."""

    def __init__(self):
        super().__init__("kubernetes")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "argocd",
            "helm",
            "k9s",
            "krew",
            "kube-apiserver",
            "kubectl",
            "kubectx",
            "kubie",
            "minikube",
            "talhelper",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "hubble-bin",
            "kubecolor",
            "kubescape",
            "talosctl-bin",
        }

    def after_update(self, store):
        # Idempotent; timedatectl is a no-op if zone already matches.
        decman.prg(
            ["krew", "install", "stern neat radar"],
            check=False,
        )
