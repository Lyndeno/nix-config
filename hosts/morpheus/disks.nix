{
  boot.supportedFilesystems = ["zfs"];
  networking.hostId = "a5d4421d";

  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;

  boot.zfs.extraPools = ["bigpool"];

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-label/nixcrypt";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixroot";
      fsType = "xfs";
    };

    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    "/data/mirror" = {
      device = "/dev/disk/by-label/mirrorpool";
      fsType = "btrfs";
      options = ["subvol=@" "compress=zstd:6"];
    };
  };
}
