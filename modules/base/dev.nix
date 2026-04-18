{
  flake.modules.nixos.docker = {
    virtualisation.docker.enable = true;
    users.users.sboynton.extraGroups = [ "docker" ];
  };

  flake.modules.nixos.nix-ld = { pkgs, ... }: {
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
  };
}
