{
  flake.modules.homeManager.tailscale = { pkgs, ... }: {
    home.packages = with pkgs; [ tailscale ];
  };
}
