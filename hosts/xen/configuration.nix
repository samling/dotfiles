{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "xen";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "0";
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  my.desktop.enable = true;
  my.hardware.asus.enable = true;
  my.hardware.keyd.enable = true;
  my.dev.docker.enable = true;
  my.dev.nixLd.enable = true;
  services.littlesnitch.enable = true;

  system.stateVersion = "25.11";
}
