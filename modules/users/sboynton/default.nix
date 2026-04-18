{
  flake.modules.homeManager.sboynton = { pkgs, ... }: {
    home.username = "sboynton";
    home.homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin then "/Users/sboynton" else "/home/sboynton";
    home.stateVersion = "24.11";

    programs.home-manager.enable = true;
  };
}
