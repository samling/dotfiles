{ pkgs, ... }:

let
  realChrome = pkgs.google-chrome.override { commandLineArgs = "--disable-pinch"; };

  # NixOS-WSL's /init spawns login shells directly into user-1000.slice,
  # which prevents user@1000.service from starting and leaves
  # /run/user/1000/bus missing. Chrome prints non-fatal dbus errors in that
  # state, but on WSLg it also fails to produce a visible window. Wrap
  # chrome so the first invocation hops into dbus-run-session to get an
  # ephemeral session bus.
  chromeWrapper = pkgs.writeShellScriptBin "google-chrome" ''
    if [ -z "$_CHROME_DBUS_WRAPPED" ] && [ ! -S "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus" ]; then
      export _CHROME_DBUS_WRAPPED=1
      exec ${pkgs.dbus}/bin/dbus-run-session -- "$0" "$@"
    fi
    exec ${realChrome}/bin/google-chrome "$@"
  '';
in
{
  # No GUI toggles — modules/home/cli.nix loads unconditionally,
  # so sboynton still gets every CLI tool, LSP, formatter, and shell config.

  # Chrome for WSLg: lets browser-based auth popups (gcloud, tsh, etc.)
  # render through WSLg without pulling in the full desktop stack. Only
  # the wrapper goes on PATH; realChrome is pulled into the closure via
  # the wrapper's exec path. xdg-utils provides a real xdg-open so CLIs
  # like tsh (which shell out to xdg-open and ignore $BROWSER) can open
  # a browser.
  home.packages = [ chromeWrapper pkgs.xdg-utils ];

  # User-level desktop entry shadows the one shipped with the chrome
  # package so xdg-open routes through our dbus-wrapping shim.
  xdg.desktopEntries.google-chrome = {
    name = "Google Chrome";
    genericName = "Web Browser";
    exec = "${chromeWrapper}/bin/google-chrome %U";
    icon = "google-chrome";
    categories = [ "Network" "WebBrowser" ];
    mimeType = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ];
  };

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
    };
  };

  # Some tools read $BROWSER directly instead of going through xdg-open.
  home.sessionVariables.BROWSER = "${chromeWrapper}/bin/google-chrome";
}
