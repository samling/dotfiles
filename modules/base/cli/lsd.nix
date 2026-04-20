{
  flake.modules.homeManager.lsd = { pkgs, ... }: {
    home.packages = with pkgs; [ lsd ];
  };
}
