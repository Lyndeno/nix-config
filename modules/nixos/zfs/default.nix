# meta.description = "ZFS support with periodic scrub and TRIM"
{
  services = {
    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };
  };

  boot.supportedFilesystems = ["zfs"];
}
