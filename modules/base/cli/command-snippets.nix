{
  flake.modules.homeManager.command-snippets = { pkgs, ... }: {
    home.packages = with pkgs; [ command-snippets ];

    home.file.".config/cs" = {
      source = ../../../config/cs;
      recursive = true;
    };
  };
}
