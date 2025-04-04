{
  modulesPath,
  lib,
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/minimal.nix")
  ];
  # Set your time zone.
  time.timeZone = "America/Edmonton";
  stylix.enable = lib.mkForce false;
  modules.hydraCache.enable = true;
}
