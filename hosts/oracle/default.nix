{modulesPath}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  # Set your time zone.
  time.timeZone = "America/Edmonton";
}
