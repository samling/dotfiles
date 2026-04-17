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
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, claude-code, hyprland-plugins, matugen, ... } @ inputs:
    let
      mkHost = hostname: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostname}/configuration.nix
          ./modules/nixos
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.overlays = [ claude-code.overlays.default ];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sboynton = {
              imports = [
                ./home.nix
                ./hosts/${hostname}/home.nix
              ];
            };
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
        "Sam-Desktop" = mkHost "Sam-Desktop";
      };
    };
}
