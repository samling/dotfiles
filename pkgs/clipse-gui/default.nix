{ ... }: {
  perSystem = { pkgs, ... }: {
    packages.clipse-gui = pkgs.callPackage ./package.nix { };
  };
}
