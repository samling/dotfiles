{
  flake.modules.homeManager.rofi = { pkgs, ... }: {
    home.packages = with pkgs; [
      wofi
      fuzzel
      rofi
      wlogout
    ];
  };
}
