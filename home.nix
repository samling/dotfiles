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
    vesktop
    obsidian
    gcc
    papirus-icon-theme
    nwg-look
    just
    ripgrep
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
    nerd-fonts.iosevka
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
    vscode-fhs
    wl-clipboard
    bc
    dconf
    glib
    qt6Packages.qt6ct

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

  home.pointerCursor = {
    name = "BreezeX-RosePine-Linux";
    package = pkgs.rose-pine-cursor;
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  gtk = {
    enable = true;
    gtk4 = {
      theme = null;
    };
    iconTheme = {
      name = "Papirus-Light";
      package = pkgs.papirus-icon-theme;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      icon-theme = "Papirus-Light";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
  };

  home.file.".config/qt6ct/colors/catppuccin-mocha.conf".text = ''
    [ColorScheme]
    active_colors=#ffcdd6f4, #ff1e1e2e, #ff1e1e2e, #ff313244, #ff585b70, #ff6c7086, #ffcdd6f4, #ffcdd6f4, #ffcdd6f4, #ff1e1e2e, #ff313244, #ff585b70, #ff89b4fa, #ff1e1e2e, #ff89b4fa, #fff38ba8, #ff45475a, #ffcdd6f4, #ff181825, #ffcdd6f4, #80cdd6f4
    disabled_colors=#ff6c7086, #ff1e1e2e, #ff1e1e2e, #ff313244, #ff585b70, #ff6c7086, #ff6c7086, #ff6c7086, #ff6c7086, #ff1e1e2e, #ff313244, #ff585b70, #ff89b4fa, #ff1e1e2e, #ff89b4fa, #fff38ba8, #ff45475a, #ffcdd6f4, #ff181825, #ffcdd6f4, #80cdd6f4
    inactive_colors=#ffcdd6f4, #ff1e1e2e, #ff1e1e2e, #ff313244, #ff585b70, #ff6c7086, #ffcdd6f4, #ffcdd6f4, #ffcdd6f4, #ff1e1e2e, #ff313244, #ff585b70, #ff89b4fa, #ff1e1e2e, #ff89b4fa, #fff38ba8, #ff45475a, #ffcdd6f4, #ff181825, #ffcdd6f4, #80cdd6f4
  '';

  home.file.".config/qt6ct/qt6ct.conf".text = ''
    [Appearance]
    icon_theme=Papirus-Light
    style=Fusion
    custom_palette=true
    color_scheme_path=/home/sboynton/.config/qt6ct/colors/catppuccin-mocha.conf

    [Interface]
    dialog_buttons_have_icons=1
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    toolbutton_style=4

    [Troubleshooting]
    force_raster_widgets=1
  '';

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "/etc/profiles/per-user/sboynton/bin/qs";
      Environment = [
        "XDG_DATA_DIRS=/etc/profiles/per-user/sboynton/share:/run/current-system/sw/share:/usr/share"
        "QT_QPA_PLATFORMTHEME=qt6ct"
        "QT_ICON_THEME=Papirus-Light"
        "QT_STYLE_OVERRIDE=Fusion"
      ];
      Restart = "always";
      RestartSec = "10s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  programs.home-manager.enable = true;
}
