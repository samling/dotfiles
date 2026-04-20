{ inputs, ... }:
{
  flake.modules.homeManager.matugen = { pkgs, ... }: {
    home.packages = [
      inputs.matugen.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home.file.".config/matugen" = {
      source = ../../../config/matugen;
      recursive = true;
    };
  };
}
