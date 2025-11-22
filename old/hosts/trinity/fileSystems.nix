{
  "/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };
  "/data/borg" = {
    device = "/dev/disk/by-label/omicron";
    fsType = "btrfs";
    options = ["noatime" "compress=zstd:6" "subvolid=256"];
  };
}
