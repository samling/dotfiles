{ ... }: {
  perSystem = { pkgs, ... }: {
    packages.littlesnitch = pkgs.callPackage ./package.nix { };
  };
}
