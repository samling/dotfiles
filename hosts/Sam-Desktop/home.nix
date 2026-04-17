{ pkgs, ... }:

{
  # No GUI toggles — modules/home/cli.nix loads unconditionally,
  # so sboynton still gets every CLI tool, LSP, formatter, and shell config.

  # Chrome for WSLg: lets browser-based auth popups (gcloud, etc.) render
  # through WSLg without pulling in the full desktop stack.
  home.packages = [
    (pkgs.google-chrome.override {
      commandLineArgs = "--disable-pinch";
    })
  ];
}
