{modulesPath}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/minimal.nix")
  ];
  # Set your time zone.
  time.timeZone = "America/Edmonton";
  modules.hydraCache.enable = true;
  stylix = {
    autoEnable = false;
  };
}
