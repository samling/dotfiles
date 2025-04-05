{
  description = "NixOS base flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1&ref=v0.48.1-b";

    hy3 = {
      url = "github:outfoxxed/hy3";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    hy3,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
    homeConfigurations = {
      "sboynton@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          #({ pkgs, system, ...}: {
          #  wayland.windowManager.hyprland = {
          #    enable = true;
          #    package = null;
          #    portalPackage = null;
          #    extraConfig = ''
          #      plugin = ${pkgs.hyprlandPlugins.hy3}/lib/libhy3.so
          #    '';
          #  };
          #})
          ./home.nix
        ];
      };
    }; 
  };
}
