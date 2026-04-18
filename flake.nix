{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
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

  outputs = inputs@{ flake-parts, import-tree, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, lib, ... }: {
      imports = [
        (import-tree.filterNot (lib.hasSuffix "hardware-configuration.nix") ./modules)
      ];

      options.flake.modules = lib.mkOption {
        type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
        default = {};
      };

      config = {
        systems = [ "x86_64-linux" ];

        flake.nixosConfigurations = let
          mkHost = { system, home }: nixpkgs.lib.nixosSystem {
            modules = system ++ [{
              home-manager.users.sboynton.imports = home;
            }];
          };
        in {
          xen = mkHost {
            system = with config.flake.modules.nixos; [
              base desktop docker nix-ld asus keyd littlesnitch xen
            ];
            home = with config.flake.modules.homeManager; [
              sboynton cli desktop hyprland asus
            ];
          };

          "Sam-Desktop" = mkHost {
            system = with config.flake.modules.nixos; [ base wsl ]
              ++ [ config.flake.modules.nixos."Sam-Desktop" ];
            home = with config.flake.modules.homeManager; [ sboynton cli ];
          };
        };
      };
    });
}
