{ config, lib, pkgs, ... }:

let
  cfg = config.services.littlesnitch;
in {
  options.services.littlesnitch = {
    enable = lib.mkEnableOption "Little Snitch network monitor daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.littlesnitch;
      description = "The Little Snitch package to use.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open TCP port 3031 (web UI) in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];
    systemd.services.littlesnitch.wantedBy = [ "multi-user.target" ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 3031 ];
  };
}
