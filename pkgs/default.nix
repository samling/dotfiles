{ final, prev }: let
  inherit (prev) lib;
  files = builtins.readDir ./.;
  isPkg = name: type:
    type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix";
  names = lib.mapAttrsToList (n: _: lib.removeSuffix ".nix" n)
    (lib.filterAttrs isPkg files);
in
  lib.genAttrs names (name: final.callPackage (./. + "/${name}.nix") { })
