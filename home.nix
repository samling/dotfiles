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
    go
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
    pure-prompt
    gitstatus
    neovim
  ];

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
