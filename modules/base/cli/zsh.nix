{
  flake.modules.homeManager.zsh = { pkgs, ... }: {
    home.packages = with pkgs; [
      pure-prompt
      gitstatus
      fastfetch
      fnm
    ];
  };
}
