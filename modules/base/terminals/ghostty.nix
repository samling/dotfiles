{
  flake.modules.homeManager.ghostty = { pkgs, ... }: {
    home.packages = with pkgs; [ ghostty ];
  };
}
