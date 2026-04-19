{ lib
, python3Packages
, fetchFromGitHub
, gtk3
, gobject-introspection
, wrapGAppsHook3
, nix-update-script
}:

python3Packages.buildPythonApplication rec {
  pname = "clipse-gui";
  version = "0.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "d7omdev";
    repo = "clipse-gui";
    rev = "fda591ad79963424d9cc0417a3a7264b9c7e5c9e";
    hash = "sha256-PIHopSFpFhSoX9K36l0JMjdINLAddoqsnyZZHK4UnY0=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [ gtk3 ];

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    pygobject3
    pycairo
    pillow
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postInstall = ''
    install -Dm644 clipse-gui.png \
      $out/share/icons/hicolor/128x128/apps/clipse-gui.png

    mkdir -p $out/share/applications
    cat > $out/share/applications/clipse-gui.desktop <<EOF
    [Desktop Entry]
    Version=${version}
    Type=Application
    Name=Clipse GUI
    GenericName=Clipboard Manager
    Comment=GTK Clipboard Manager
    Exec=$out/bin/clipse-gui
    Icon=clipse-gui
    Terminal=false
    Categories=Utility;GTK;
    StartupNotify=true
    StartupWMClass=org.d7om.ClipseGUI
    EOF
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A GTK3 GUI for the clipse clipboard manager";
    homepage = "https://github.com/d7omdev/clipse-gui";
    license = lib.licenses.mit;
    mainProgram = "clipse-gui";
  };
}
