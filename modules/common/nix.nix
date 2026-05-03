{ inputs, ... }:
{
  flake.modules.nixos.common = {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://hyprland.cachix.org" "https://ghostty.cachix.org" ];
      trusted-substituters = [ "https://hyprland.cachix.org" "https://ghostty.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];
    };

    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      (final: prev: inputs.self.packages.${prev.stdenv.hostPlatform.system} or {})
      # TEMP-OVERRIDE: wireshark 4.6.5 src hash; remove once nixos-unstable advances past nixpkgs#515269.
      (final: prev: {
        wireshark = prev.wireshark.overrideAttrs (old: {
          src = prev.fetchFromGitLab {
            owner = "wireshark";
            repo = "wireshark";
            tag = "v${old.version}";
            hash = "sha256-Zvrwxjp4LK2J3QnxmPxKKrU01YHQvPyp54UWzeGNCjA=";
          };
        });
      })
    ];
  };
}
