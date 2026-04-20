{ config, inputs, ... }:
{
  flake.modules.nixos.desktop = { lib, pkgs, ... }: {
    imports = [ inputs.hyprland.nixosModules.default ];

    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
    };

    programs.regreet = {
      enable = true;
      settings = {
        GTK = {
          application_prefer_dark_theme = true;
          cursor_theme_name = lib.mkForce "BreezeX-RosePine-Linux";
          font_name = lib.mkForce "Cantarell 16";
          icon_theme_name = lib.mkForce "Papirus-Dark";
          theme_name = lib.mkForce "catppuccin-mocha-lavender-standard";
        };
        commands = {
          reboot = [ "systemctl" "reboot" ];
          poweroff = [ "systemctl" "poweroff" ];
        };
        appearance = {
          greeting_msg = "Welcome back!";
        };
        widget.clock = {
          format = "%a %H:%M";
          resolution = "500ms";
          timezone = "America/Los_Angeles";
          label_width = 150;
        };
      };
    };

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;

    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    services.udisks2.enable = true;

    environment.systemPackages = with pkgs; [
      (catppuccin-gtk.override {
        variant = "mocha";
        accents = [ "lavender" ];
        size = "standard";
      })
      papirus-icon-theme
      rose-pine-cursor
    ];
  };

  flake.modules.homeManager.desktop = { pkgs, ... }: {
    imports = with config.flake.modules.homeManager; [ ghostty ];

    home.packages = with pkgs; [
      # Terminals / file manager
      kitty
      thunar

      # Browsers / chat / editors
      (google-chrome.override {
        commandLineArgs = "--disable-pinch";
      })
      vesktop
      obsidian
      vscode-fhs

      # Media
      mpv

      # Audio / network / power applets
      bluez
      blueman
      networkmanagerapplet
      pulseaudio
      playerctl
      brightnessctl
      lm_sensors

      # Disk / misc
      udiskie
      distrobox
      parsec-bin

      # Clipboard
      wl-clipboard

      # Theming tools
      papirus-icon-theme
      nwg-look
      dconf
      glib
      qt6Packages.qt6ct

      # Fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
    ];

    services.udiskie.enable = true;

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
      theme = {
        name = "catppuccin-mocha-lavender-standard";
        package = pkgs.catppuccin-gtk.override {
          variant = "mocha";
          accents = [ "lavender" ];
          size = "standard";
        };
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
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
  };
}
