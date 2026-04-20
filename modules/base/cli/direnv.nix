{
  flake.modules.homeManager.direnv = { pkgs, ... }: {
    home.packages = with pkgs; [ direnv ];
  };
}
