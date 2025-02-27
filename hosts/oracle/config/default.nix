{
  modulesPath,
  lib,
  flake,
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/minimal.nix")
    flake.modules.nixos.common
  ];
  # Set your time zone.
  time.timeZone = "America/Edmonton";
  stylix.enable = lib.mkForce false;
  mods.hydraCache.enable = true;
}
