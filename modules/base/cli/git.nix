{
  flake.modules.homeManager.git = { pkgs, ... }: {
    home.packages = with pkgs; [
      git
      gh
      delta
      gitmux
      pre-commit
    ];

    home.file.".gitmux.conf".source = ../../../config/gitmux.conf;
  };
}
