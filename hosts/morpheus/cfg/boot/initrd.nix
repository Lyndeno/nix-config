{
  systemd.enable = true;

  luks.devices."cryptroot".device = "/dev/disk/by-label/nixcrypt";
}
