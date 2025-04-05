{ config, pkgs, ... }:

let
  hyprlandConfContent = builtins.readFile ./hyprland.conf;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sboynton";
  home.homeDirectory = "/home/sboynton";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
      # From keywords.conf
      terminal = "wezterm";
      fileManager = "thunar";
      menu = "fuzzel";
      hyprlock = "hyprlock";
      mainMod = "SUPER"; # From keybindings.conf.tmpl

      # From envvars.conf, monitors.conf.tmpl, autostart.conf.tmpl
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
        "GDK_SCALE,2"
        "QT_QPA_PLATFORMTHEME,qt6ct"
      ];

      # From monitors.conf.tmpl
      monitor = [ ",highres,auto,2" ];
      xwayland = { force_zero_scaling = true; };

      # From plugins.conf
      plugin = {
        hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(111111)";
          workspace_method = "center current";
          enable_gesture = true;
          gesture_fingers = 3;
          gesture_distance = 150;
          gesture_positive = false;
        };
        hyprbars = {
          bar_height = 28;
          bar_color = "rgb(1e1e2e)";
          bar_text_size = 12;
          bar_text_font = "Iosevka";
          bar_button_padding = 8;
          bar_padding = 8;
          bar_precedence_over_border = true;
          "hyprbars-button" = [
            "rgb(1e1e2e), 20, , hyprctl dispatch killactive"
            "rgb(1e1e2e), 20, , hyprctl dispatch fullscreen 1"
            "rgb(1e1e2e), 20, , hyprctl dispatch togglefloating"
          ];
         };
        hy3 = {
          autotile = {
            enable = true;
          };
          tabs = {
            height = 16;
            padding = 12;
            radius = 8;
            border_width = 0;
            opacity = 1.0;
            render_text = true;
            text_font = "Iosevka";
            text_height = 10;
            blur = false;
            col = {
              active = "rgba(89B4FADF)";
              active.text = "rgba(00000000)";
              inactive = "rgba(8c8fa1DF)";
              inactive.text = "rgba(00000000)";
              urgent = "rgba(df8e1dFF)";
              urgent.text = "rgba(00000000)";
            };
          };
        };
      };

      # From keybindings.conf.tmpl
      binds = { allow_workspace_cycles = true; };
      bind = [
        "$mainMod, W, killactive,"
        # Binds not using 'exec' or 'submap'
        "$mainMod, V, togglefloating,"
        "$mainMod SHIFT, P, pin"
        "$mainMod, Tab, workspace, previous"
        "$mainMod, H, hy3:movefocus, l"
        "$mainMod, L, hy3:movefocus, r"
        "$mainMod, K, hy3:movefocus, u"
        "$mainMod, J, hy3:movefocus, d"
        "$mainMod, T, hy3:makegroup, tab"
        "$mainMod, U, hy3:changegroup, untab"
        "$mainMod SHIFT, H, hy3:movewindow, l"
        "$mainMod SHIFT, L, hy3:movewindow, r"
        "$mainMod SHIFT, K, hy3:movewindow, u"
        "$mainMod SHIFT, J, hy3:movewindow, d"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod, N, workspace, e+1"
        "$mainMod, P, workspace, e-1"
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
        "$mainMod, grave, togglespecialworkspace, magic"
        "$mainMod SHIFT, grave, movetoworkspacesilent, special:magic"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];
      bindm = [ # From keybindings.conf.tmpl
        "$mainMod, mouse:272, movewindow"
        "$mainMod SHIFT, mouse:272, resizewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # From input.conf.tmpl
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "numpad:mac";
        kb_rules = "";
        follow_mouse = 1;
        accel_profile = "flat";
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          tap-and-drag = false;
          clickfinger_behavior = true;
          scroll_factor = 0.2;
        };
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      # From layout.conf.tmpl
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 1;
        col.active_border = "rgb(99EEFF) rgb(FF99FF) 45deg";
        col.inactive_border = "rgba(595959aa)";
        resize_on_border = true;
        extend_border_grab_area = 20;
        allow_tearing = false;
        layout = "hy3";
      };
      decoration = {
        rounding = 0;
        # rounding_power = 2; # Not directly mapped in Nix module? Omit for now.
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = { # Nested structure assumed, check module docs if needed
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = { # Nested structure assumed, check module docs if needed
          enabled = false;
          # size = 3; # Use blur_size? Omit for now.
          # passes = 1; # Use blur_passes? Omit for now.
          # vibrancy = 0.1696; # Use blur_vibrancy? Omit for now.
        };
      };
      # animations moved to extraConfig
      dwindle = { # Kept for potential plugin use/defaults
        pseudotile = true;
        preserve_split = true;
      };
      master = { new_status = "master"; };
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        vfr = true;
        focus_on_activate = true;
      };
      cursor = { no_warps = true; };
      group = {
        col.border_active = "0xD089b4fa"; # Hex colors need quotes
        groupbar = {
          col.active = "0xC089b4fa";
          col.locked_active = "0xC089b4fa";
          col.inactive = "0xC06c7086";
          col.locked_inactive = "0xC06c7086";
          gradient_rounding = 8;
          font_family = "Iosevka";
          font_size = 12;
          height = 16;
          indicator_height = 0;
          gradients = true;
          render_titles = true;
        };
      };

      # From windowrules.conf.tmpl
      windowrule = [
        "bordercolor rgb(DF8E1D), fullscreen:1"
        "bordersize 1, floating:0, onworkspace:f[1]"
        "rounding 0, floating:0, onworkspace:f[1]"
        "plugin:hyprbars:nobar, floating:0"
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        "bordercolor rgb(DF8E1D), pinned:1"
        "float,class:(org.kde.dolphin)"
        #"float,class:(org.gnome.TextEditor)" # Keep commented rules commented
        "float,class:(org.gnome.*)"
        "float,class:(Thunar)"
        "float,class:(gnome-power-statistics)"
        "float,class:(org.pulseaudio.pavucontrol)"
        "float,class:(piper)"
        "float,class:(localsend)"
        "float,class:(mpv)"
        "float,class:(feh)"
        "float,class:(xdg-desktop-portal-gtk)"
        "float,class:(nm-connection-editor)"
        "float,class:(nm-openconnect-auth-dialog)"
        "float,class:(nwg-look)"
        "float,title:(Bitwarden),class:(chrome-.*)"
        "float,class:(insync)"
        "float,class:(com.github.hluk.copyq)"
        "float,title:(Picture in picture)"
      ];
      workspace = [ # From windowrules.conf.tmpl
        "f[1], gapsout:0, gapsin:0"
      ];
      # workspace list from workspaces.conf.tmpl was empty for hostname != "endeavor"

    }; # End of settings

    extraConfig = ''
      # --- From bar.conf ---
      exec-once = waybar
      exec-once = ags run 2> /tmp/ags.log

      # --- From keybindings.conf.tmpl (exec binds) ---
      bind = SUPER, E, exec, thunar # Replaced $fileManager
      bind = SUPER, space, exec, fuzzel # Replaced $menu
      bind = SUPER SHIFT, R, exec, /home/sboynton/.config/swww/swww_randomize_multi.sh '/home/sboynton/Insync/samlingx@gmail.com/Google Drive/Apps/Desktoppr' && notify-send "Cycled wallpaper" # Replaced ~, used full path
      bind = SUPER SHIFT, bracketleft, exec, hyprshade toggle blue-light-filter
      bind = SUPER SHIFT, W, exec, pkill waybar && hyprctl dispatch exec waybar
      bind = SUPER SHIFT, C, exec, copyq toggle
      bind = ALT, TAB, exec, ags toggle picker- # primaryMonitor was empty
      bind = , print, exec, swscreenshot-gui
      bind = CONTROL SUPER, 3, exec, grim $(xdg-user-dir)/Pictures/Screenshots/$(date +'%s_grim.png') && notify-send "Screenshot saved" # Replaced $mainMod
      bind = CTRL, print, exec, grim -g "$(slurp)" $(xdg-user-dir)/Pictures/Screenshots/$(date +'%s_grim.png') && notify-send "Screenshot saved"
      bind = CTRL SUPER, 4, exec, grim -g "$(slurp)" $(xdg-user-dir)/Pictures/Screenshots/$(date +'%s_grim.png') && notify-send "Screenshot saved" # Replaced $mainMod
      bind = SUPER CONTROL ALT, L, exec, hyprlock # Replaced $hyprlock

      # --- From keybindings.conf.tmpl (submap related binds) ---
      bind = ALT, TAB, submap, alt-tab
      submap=alt-tab
      bind = , Escape, submap, reset
      submap=reset
      bind = SUPER, R, submap, resize # Replaced $mainMod
      submap=resize
      bind = , H, resizeactive, -5% 0%
      bind = , J, resizeactive, 0% -5%
      bind = , K, resizeactive, 0% 5%
      bind = , L, resizeactive, 5% 0%
      bind = , equal, resizeactive, 5% 5%
      bind = , minus, resizeactive, -5% -5%
      bind = , Return, submap, reset
      bind = , Escape, submap, reset # Duplicate Escape bind from alt-tab submap

      # --- From keybindings.conf.tmpl (multimedia binds with exec) ---
      bindel = ,XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise
      bindel = ,XF86AudioLowerVolume, exec, swayosd-client --output-volume lower
      bindel = ,XF86AudioMute, exec, swayosd-client --output-volume mute-toggle
      bindel = ,XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle
      bindel = ,XF86MonBrightnessUp, exec, swayosd-client --brightness=+10
      bindel = ,XF86MonBrightnessDown, exec, swayosd-client --brightness=-10
      bindl = , XF86AudioNext, exec, playerctl next
      bindl = , XF86AudioPause, exec, playerctl play-pause
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous

      # --- From autolaunch.conf.tmpl (hostname != "laptop") ---
      exec-once = [workspace 1 silent] google-chrome-stable
      exec-once = [workspace 1 silent] firefox
      exec-once = [workspace 2 silent] wezterm
      exec-once = [workspace 3 silent] gtk-launch cursor
      exec-once = [workspace 4 silent] obsidian
      exec-once = [workspace 7 silent] vesktop
      exec-once = [workspace 7 silent] slack
      exec-once = [workspace 7 silent] signal-desktop

      # --- From autostart.conf.tmpl ---
      exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once = dbus-update-activation-environment --systemd HYPRLAND_INSTANCE_SIGNATURE
      exec-once = nm-applet --indicator
      exec-once = swayosd-server
      exec-once = dunst
      exec-once = systemctl --user start hyprpolkitagent
      exec-once = /home/sboynton/.config/swww/swww_randomize_multi_daemon.sh '/home/sboynton/Insync/samlingx@gmail.com/Google Drive/Apps/Desktoppr' # Replaced ~, used full path
      exec-once = SHOW_DEFAULT_ICON=true hyprswitch init --show-title --size-factor 4.5 --workspaces-per-row 5 &
      exec = gsettings set org.gnome.desktop.interface gtk-theme "catppuccin-mocha-lavender-standard+default"
      exec = gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
      exec-once = gsettings set org.gnome.desktop.interface cursor-theme BreezeX-RosePine
      exec-once = gsettings set org.gnome.desktop.interface cursor-size 24
      exec-once = hypridle
      exec-once = hyprpm reload -n
      exec-once = /home/sboynton/.local/lib/import_env tmux # Replaced $HOME
      exec-once = copyq --start-server
      exec-once = insync start

      # --- From laptop.conf.tmpl (empty for non-laptop) ---

      # --- From layout.conf.tmpl (animations - safer in extraConfig) ---
      bezier = easeOutQuint,0.23,1,0.32,1
      bezier = easeInOutCubic,0.65,0.05,0.36,1
      bezier = linear,0,0,1,1
      bezier = almostLinear,0.5,0.5,0.75,1.0
      bezier = quick,0.15,0,0.1,1
      animation = global, 1, 10, default
      animation = border, 1, 5.39, easeOutQuint
      animation = windows, 1, 4.79, easeOutQuint
      animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
      animation = windowsOut, 1, 1.49, linear, popin 87%
      animation = fadeIn, 1, 1.73, almostLinear
      animation = fadeOut, 1, 1.46, almostLinear
      animation = fade, 1, 3.03, quick
      animation = layers, 1, 3.81, easeOutQuint
      animation = layersIn, 1, 4, easeOutQuint, fade
      animation = layersOut, 1, 1.5, linear, fade
      animation = fadeLayersIn, 1, 1.79, almostLinear
      animation = fadeLayersOut, 1, 1.39, almostLinear
      animation = workspaces, 1, 1.94, almostLinear, fade
      animation = workspacesIn, 1, 1.21, almostLinear, fade
      animation = workspacesOut, 1, 1.94, almostLinear, fade
    ''; # End of extraConfig
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sboynton/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
