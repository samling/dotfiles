{
  flake.modules.homeManager.rofi = { pkgs, ... }: {
    home.packages = with pkgs; [
      wofi
      fuzzel
      rofi
      wlogout
    ];

    home.file.".config/rofi" = {
      source = ../../../config/rofi;
      recursive = true;
    };
  };
}
