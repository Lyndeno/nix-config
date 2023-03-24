{
  modules.services.zed.enable = true;

  boot.supportedFilesystems = ["zfs"];
  networking.hostId = "a5d4421d";

  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;

  boot.zfs.extraPools = ["bigpool"];

  fileSystems = {
    "/" = {
      device = "nixpool/nixos/root";
      fsType = "zfs";
      options = ["zfsutil" "X-mount.mkdir"];
    };

    "/home" = {
      device = "nixpool/nixos/home";
      fsType = "zfs";
      options = ["zfsutil" "X-mount.mkdir"];
    };

    "/var" = {
      device = "nixpool/nixos/var";
      fsType = "zfs";
      options = ["zfsutil" "X-mount.mkdir"];
    };

    "/var/lib" = {
      device = "nixpool/nixos/var/lib";
      fsType = "zfs";
      options = ["zfsutil" "X-mount.mkdir"];
    };

    "/var/log" = {
      device = "nixpool/nixos/var/log";
      fsType = "zfs";
      options = ["zfsutil" "X-mount.mkdir"];
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

  swapDevices = [
    {device = "/dev/disk/by-label/nixswap";}
  ];
}
