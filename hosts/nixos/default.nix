{ ... }: {
  networking.hostName = "nixos";

  imports = [ ./hardware-configuration.nix ];

  # Match your install — check /etc/nixos/configuration.nix if different
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
