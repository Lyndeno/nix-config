{
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
}
