{ inputs, ... }:
{
  flake.modules.nixos.base = { pkgs, lib, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      inputs.claude-code.overlays.default
      (final: prev: import ../../pkgs { inherit final prev; })
    ];

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    networking.networkmanager.enable = lib.mkDefault true;
    services.openssh.enable = lib.mkDefault true;

    time.timeZone = lib.mkDefault "America/Los_Angeles";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    users.users.sboynton = {
      isNormalUser = true;
      description = "Sam Boynton";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
    };

    programs.zsh.enable = true;

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  };
}
