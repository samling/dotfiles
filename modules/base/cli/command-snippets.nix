{
  flake.modules.homeManager.command-snippets = { pkgs, ... }: {
    home.packages = with pkgs; [ command-snippets ];
  };
}
