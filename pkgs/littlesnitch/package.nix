{ lib, stdenv, fetchurl, autoPatchelfHook, zstd, pam, sqlite }:

stdenv.mkDerivation (finalAttrs: {
  pname = "littlesnitch";
  version = "1.0.2-1";

  src = fetchurl {
    url = "https://obdev.at/downloads/littlesnitch-linux/littlesnitch-${finalAttrs.version}-x86_64.pkg.tar.zst";
    hash = "sha256-GFGawy8NXr0TY/NQNOJtaKnQy/cqIs6Dhtx8h8OEIPc=";
  };

  nativeBuildInputs = [ autoPatchelfHook zstd ];
  buildInputs = [ pam sqlite stdenv.cc.cc.lib ];

  unpackPhase = ''
    runHook preUnpack
    mkdir -p source
    tar --use-compress-program=unzstd -xf $src -C source
    cd source
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 usr/bin/littlesnitch          $out/bin/littlesnitch
    install -Dm644 usr/lib/systemd/system/littlesnitch.service \
                                                 $out/lib/systemd/system/littlesnitch.service
    substituteInPlace $out/lib/systemd/system/littlesnitch.service \
      --replace-fail /usr/bin/littlesnitch $out/bin/littlesnitch
    install -Dm644 usr/share/metainfo/at.obdev.littlesnitch.metainfo.xml \
                                                 $out/share/metainfo/at.obdev.littlesnitch.metainfo.xml
    install -Dm644 usr/share/doc/littlesnitch/copyright \
                                                 $out/share/doc/littlesnitch/copyright
    runHook postInstall
  '';

  meta = {
    description = "Little Snitch network monitor for Linux";
    homepage = "https://obdev.at/littlesnitch-linux";
    license = with lib.licenses; [ gpl2Only unfree ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "littlesnitch";
  };
})
