{
  services = {
    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };
  };

  boot.supportedFilesystems = ["zfs"];
}
