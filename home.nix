{ pkgs, ... }: {
  home.username = "sboynton";
  home.homeDirectory = "/home/sboynton";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    bat
    bluez
    kitty
    wofi
    vim
    git
    fnm
    duf
    lsd
    fzf
    claude-code
    go
    google-chrome
    kubectl
    kubecolor
    fuzzel
    ghostty
    rofi
    wlogout
    quickshell
    nerd-fonts.jetbrains-mono
    tailscale
    brightnessctl
    pulseaudio
    playerctl
    udiskie
    blueman
    networkmanagerapplet
    hyprpolkitagent
    hypridle
    keyd
    hyprshell
    copyq
    clipse
    zinit
    fastfetch
    pure-prompt
    gitstatus
    neovim
    tmux
    direnv
    gitmux
    cmatrix
    wl-clipboard
    bc

    # Neovim LSP servers
    lua-language-server
    typescript-language-server
    rust-analyzer
    gopls
    terraform-ls
    yaml-language-server
    dockerfile-language-server-nodejs
    buf
    nil

    # Neovim formatters
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

  home.file.".tmux.conf".source = ./config/tmux/tmux.conf;

  home.file.".tmux/scripts" = {
    source = ./config/tmux/scripts;
    recursive = true;
  };

  home.file.".tmux/kube-tmux" = {
    source = ./config/tmux/kube-tmux;
    recursive = true;
  };

  home.file.".gitmux.conf".source = ./config/gitmux.conf;

  home.file.".config/ghostty" = {
    source = ./config/ghostty;
    recursive = true;
  };

  home.file.".config/nvim" = {
    source = ./config/nvim;
    recursive = true;
  };

  home.file.".config/hypr" = {
    source = ./config/hypr;
    recursive = true;
  };

  home.file.".config/quickshell" = {
    source = ./config/quickshell;
    recursive = true;
  };

  home.file.".zsh" = {
    source = ./config/zsh;
    recursive = true;
  };

  home.file.".zshrc".source = ./config/zshrc;

  home.file.".zsh/zinit".source = "${pkgs.zinit}/share/zinit";

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "/etc/profiles/per-user/sboynton/bin/qs";
      Restart = "always";
      RestartSec = "10s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  programs.home-manager.enable = true;
}
