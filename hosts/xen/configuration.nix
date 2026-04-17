{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "xen";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  my.desktop.enable = true;
  my.hardware.asus.enable = true;
  my.hardware.keyd.enable = true;
  my.dev.docker.enable = true;
  my.dev.nixLd.enable = true;
  services.littlesnitch.enable = true;

  system.stateVersion = "25.11";
}
