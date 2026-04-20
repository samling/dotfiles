{
  flake.modules.homeManager.tmux = { pkgs, ... }: {
    home.packages = with pkgs; [ tmux ];

    home.file.".config/tmux/plugins/tpm" = {
      source = builtins.fetchGit {
        url = "https://github.com/tmux-plugins/tpm";
        rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
      };
      recursive = true;
    };

    home.file.".tmux.conf".source = ../../../config/tmux/tmux.conf;

    home.file.".tmux/scripts" = {
      source = ../../../config/tmux/scripts;
      recursive = true;
    };

    home.file.".tmux/kube-tmux" = {
      source = ../../../config/tmux/kube-tmux;
      recursive = true;
    };
  };
}
