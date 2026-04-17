{ config, lib, inputs, ... }:

let
  cfg = config.my.wsl;
in {
  imports = [ inputs.nixos-wsl.nixosModules.default ];

  options.my.wsl.enable = lib.mkEnableOption
    "NixOS-WSL integration (WSL2 — defaults networking/user to Windows-hosted values)";

  config = lib.mkIf cfg.enable {
    wsl.enable = true;
    wsl.defaultUser = "sboynton";

    # WSL2 gets its network stack from Windows; NetworkManager has nothing to do.
    # common.nix sets it via mkDefault, so we force-disable here.
    networking.networkmanager.enable = lib.mkForce false;
  };
}
