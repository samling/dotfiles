{
  flake.modules.homeManager.ghostty = { pkgs, ... }: {
    home.packages = with pkgs; [ ghostty ];

    home.file.".config/ghostty" = {
      source = ../../../config/ghostty;
      recursive = true;
    };
  };
}
