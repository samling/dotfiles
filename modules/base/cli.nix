{ config, ... }:
{
  flake.modules.homeManager.cli = {
    imports = with config.flake.modules.homeManager; [
      cli-core
      dev-tools
      git
      zsh
      neovim
      tmux
      kubernetes
      media
      direnv
      lsd
      command-snippets
      tailscale
      teleport
    ];
  };
}
