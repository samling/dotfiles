{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.my.desktop;
in {
  imports = [ inputs.hyprland.nixosModules.default ];

  options.my.desktop.enable = lib.mkEnableOption
    "graphical desktop stack (hyprland, portal, greeter, audio, bluetooth, power, theming)";

  config = lib.mkIf cfg.enable {
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
}
