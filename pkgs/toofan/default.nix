{ ... }: {
  perSystem = { pkgs, ... }: {
    packages.toofan = pkgs.callPackage ./package.nix { };
  };
}
