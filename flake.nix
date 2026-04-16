{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland/v0.54.3";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    claude-code.url = "github:sadjow/claude-code-nix";
    asus-fan.url = "github:ThatOneCalculator/asus-5606-fan-state";
    matugen.url = "github:/InioX/Matugen";
  };

  outputs = { nixpkgs, home-manager, hyprland, hyprland-plugins, claude-code, asus-fan, matugen, ... }:
    let
      mkHost = hostname: nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/${hostname}/configuration.nix
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.overlays = [ claude-code.overlays.default ];
          }
          hyprland.nixosModules.default
          asus-fan.nixosModules.default
          {
            services.asus-fan-state.package = asus-fan.packages.x86_64-linux.default;
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sboynton = import ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit hyprland-plugins matugen;
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        nixos = mkHost "nixos";
        xen = mkHost "xen";
      };
    };
}
