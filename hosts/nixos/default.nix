{ ... }: {
  networking.hostName = "nixos";

  # Import your hardware config generated during install
  imports = [ ./hardware-configuration.nix ];

  # Host-specific settings go here
}
