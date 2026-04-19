{ ... }: {
  perSystem = { pkgs, ... }: {
    packages.teleport-bin = pkgs.callPackage ./package.nix { };
  };
}
