{
  flake.modules.homeManager.dev-tools = { pkgs, ... }: {
    home.packages = with pkgs; [
      go
      gcc
      gnumake
      python3
    ];
  };
}
