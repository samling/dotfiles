{
  flake.modules.nixos.xen = {
    imports = [ ./hardware-configuration.nix ];

    networking.hostName = "xen";
    nixpkgs.hostPlatform = "x86_64-linux";

    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.consoleMode = "0";
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.canTouchEfiVariables = true;

    home-manager.users.sboynton.my.home.hyprland.monitors = ''
      monitor=,preferred,auto,1.5

      xwayland {
        force_zero_scaling = true
      }
    '';

    system.stateVersion = "25.11";
  };
}
