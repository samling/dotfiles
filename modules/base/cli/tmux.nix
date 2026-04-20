{
  flake.modules.homeManager.tmux = { pkgs, ... }: {
    home.packages = with pkgs; [ tmux ];
  };
}
