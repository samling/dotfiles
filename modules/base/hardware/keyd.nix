{
  flake.modules.nixos.keyd = {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings.main.capslock = "overload(control, esc)";
        settings.main."f23+leftshift+leftmeta" = "M-A-c";
      };
    };

    environment.etc."libinput/local-overrides.quirks".text = ''
      [Serial Keyboards]
      MatchUdevType=keyboard
      MatchName=keyd*keyboard
      AttrKeyboardIntegration=internal
    '';
  };
}
