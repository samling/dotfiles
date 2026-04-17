{ config, lib, pkgs, ... }:

let
  cfg = config.my.dev;
in {
  options.my.dev = {
    docker.enable = lib.mkEnableOption "docker daemon and docker group for sboynton";
    nixLd.enable = lib.mkEnableOption "nix-ld for running non-nix dynamically-linked binaries";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.docker.enable {
      virtualisation.docker.enable = true;
      users.users.sboynton.extraGroups = [ "docker" ];
    })

    (lib.mkIf cfg.nixLd.enable {
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        openssl
        curl
        glib
        libxml2
        icu
        nss
        nspr
        fontconfig
        freetype
        libx11
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxrandr
        libxrender
        libxtst
        alsa-lib
        cups
        dbus
        expat
        libdrm
        libxkbcommon
        mesa
        pango
        cairo
        gtk3
      ];
    })
  ];
}
