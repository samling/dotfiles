{ config, lib, ... }:

let
  cfg = config.my.hardware.keyd;
in {
  options.my.hardware.keyd.enable = lib.mkEnableOption
    "keyd with capslock→ctrl/esc remap and libinput internal-keyboard quirk";

  config = lib.mkIf cfg.enable {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings.main.capslock = "overload(control, esc)";
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
