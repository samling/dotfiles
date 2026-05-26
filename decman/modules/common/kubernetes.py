import decman
from decman.plugins import pacman, aur


class KubernetesModule(decman.Module):
    """K8s CLI tooling. Mirrors `modules/common/kubernetes.nix`."""

    KREW_PLUGINS: frozenset[str] = frozenset({"stern", "neat", "radar"})

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
            "talosctl",
            "talhelper",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "flux-bin",
            "hubble-bin",
            "kubecolor",
            "kubescape",
            "vcluster-bin",
        }

    def after_update(self, store):
        # Reconcile sboynton's krew plugins against KREW_PLUGINS only when
        # the declared set changed since the last apply. Snapshot lives in
        # the decman store so we don't re-shell out to kubectl on every run.
        # Manual changes to the user's krew install on disk are NOT
        # reconciled — invalidate the store key if you need a re-sync.
        key = f"_krew_plugins_{self.name}"
        store.ensure(key, [])
        prev = set(store[key])
        if prev == self.KREW_PLUGINS:
            return

        to_install = sorted(self.KREW_PLUGINS - prev)
        to_remove = sorted(prev - self.KREW_PLUGINS)

        if to_install:
            decman.prg(
                ["kubectl", "krew", "install", *to_install],
                user="sboynton",
                mimic_login=True,
                check=False,
            )
        if to_remove:
            decman.prg(
                ["kubectl", "krew", "uninstall", *to_remove],
                user="sboynton",
                mimic_login=True,
                check=False,
            )

        store[key] = sorted(self.KREW_PLUGINS)
