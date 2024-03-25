{
  "/" = {
    device = "/dev/disk/by-label/nixroot";
    fsType = "xfs";
  };

  "/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };
}
