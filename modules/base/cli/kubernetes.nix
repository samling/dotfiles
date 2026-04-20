{
  flake.modules.homeManager.kubernetes = { pkgs, ... }: {
    home.packages = with pkgs; [
      kubectl
      kubecolor
      krew
      kubectx
      talhelper
      talosctl
    ];
  };
}
