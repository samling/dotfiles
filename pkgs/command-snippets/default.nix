{ ... }: {
  perSystem = { pkgs, ... }: {
    packages.command-snippets = pkgs.callPackage ./package.nix { };
  };
}
