{
  flake.modules.nixos.littlesnitch = { config, lib, pkgs, ... }: {
    options.services.littlesnitch = {
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

    config = {
      environment.systemPackages = [ config.services.littlesnitch.package ];
      systemd.packages = [ config.services.littlesnitch.package ];
      systemd.services.littlesnitch.wantedBy = [ "multi-user.target" ];

      networking.firewall.allowedTCPPorts =
        lib.mkIf config.services.littlesnitch.openFirewall [ 3031 ];
    };
  };
}
