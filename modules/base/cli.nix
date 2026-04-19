{
  flake.modules.homeManager.cli = { pkgs, ... }: {
    home.packages = with pkgs; [
      bat
      delta
      wget
      watch
      viddy
      killall
      read-edid
      v4l-utils
      libnotify
      glib
      vim
      gh
      tree
      btop
      htop
      zoxide
      gnumake
      inotify-tools
      fd
      imagemagick
      just
      ripgrep
      git
      fnm
      duf
      lsd
      eza
      file
      fzf
      go
      gcc
      bc
      unzip
      python3
      yt-dlp
      chafa
      ffmpeg
      nvd
      tailscale
      toofan
      littlesnitch
      pre-commit

      # Shell / multiplexer / editor
      zinit
      fastfetch
      pure-prompt
      gitstatus
      neovim
      tmux
      direnv
      gitmux
      cmatrix
      claude-code
      command-snippets

      # Kubernetes / cloud
      kubectl
      kubecolor
      krew
      kubectx
      talhelper
      talosctl

      # Neovim LSP servers
      lua-language-server
      typescript-language-server
      rust-analyzer
      gopls
      terraform-ls
      yaml-language-server
      dockerfile-language-server
      buf
      nil

      # Neovim formatters / misc
      stylua
      black
      isort
      shfmt
      jq
      yq
    ];

    home.file.".config/tmux/plugins/tpm" = {
      source = builtins.fetchGit {
        url = "https://github.com/tmux-plugins/tpm";
        rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
      };
      recursive = true;
    };

    home.file.".tmux.conf".source = ../../config/tmux/tmux.conf;

    home.file.".tmux/scripts" = {
      source = ../../config/tmux/scripts;
      recursive = true;
    };

    home.file.".tmux/kube-tmux" = {
      source = ../../config/tmux/kube-tmux;
      recursive = true;
    };

    home.file.".gitmux.conf".source = ../../config/gitmux.conf;

    home.file.".config/nvim" = {
      source = ../../config/nvim;
      recursive = true;
    };

    home.file.".config/lsd" = {
      source = ../../config/lsd;
      recursive = true;
    };

    home.file.".config/cs" = {
      source = ../../config/cs;
      recursive = true;
    };

    home.file.".zsh" = {
      source = ../../config/zsh;
      recursive = true;
    };

    home.file.".zshrc".source = ../../config/zshrc;

    home.file.".zsh/zinit".source = "${pkgs.zinit}/share/zinit";

    # Opt out of Teleport client auto-updates. CAU downloads a generic-Linux
    # tsh into ~/.tsh/bin that can't run on NixOS (no dynamic loader);
    # keep the autoPatchelf'd teleport-bin from PATH instead.
    home.sessionVariables.TELEPORT_TOOLS_VERSION = "off";
  };
}
