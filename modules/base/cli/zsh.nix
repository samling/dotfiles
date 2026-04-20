{
  flake.modules.homeManager.zsh = { pkgs, ... }: {
    home.packages = with pkgs; [
      zinit
      pure-prompt
      gitstatus
      fastfetch
      fnm
    ];

    home.file.".zsh" = {
      source = ../../../config/zsh;
      recursive = true;
    };

    home.file.".zshrc".source = ../../../config/zshrc;

    home.file.".zsh/zinit".source = "${pkgs.zinit}/share/zinit";
  };
}
