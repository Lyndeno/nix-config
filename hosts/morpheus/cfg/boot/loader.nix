{lib}: {
  systemd-boot.enable = lib.mkForce false;
  efi.canTouchEfiVariables = true;
}
