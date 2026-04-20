{
  flake.modules.homeManager.teleport = {
    # Opt out of Teleport client auto-updates. CAU downloads a generic-Linux
    # tsh into ~/.tsh/bin that can't run on NixOS (no dynamic loader);
    # keep the autoPatchelf'd teleport-bin from PATH instead.
    home.sessionVariables.TELEPORT_TOOLS_VERSION = "off";
  };
}
