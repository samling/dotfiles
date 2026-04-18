{ inputs, ... }:
{
  flake.modules.nixos.wsl = { lib, ... }: {
    imports = [ inputs.nixos-wsl.nixosModules.default ];

    wsl.enable = true;
    wsl.defaultUser = "sboynton";

    # WSL2 gets its network stack from Windows; NetworkManager has nothing to do.
    # base sets it via mkDefault, so we force-disable here.
    networking.networkmanager.enable = lib.mkForce false;
  };
}
