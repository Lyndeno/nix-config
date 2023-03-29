let
  rootSubvol = subvol: {
    device = "/dev/disk/by-label/linuxdata";
    fsType = "btrfs";
    options = ["noatime" "compress=zstd" "subvol=${subvol}" "discard=async"];
  };
in {
  boot.initrd.luks.devices = {
    "nixcrypt" = {
      preLVM = true;
      device = "/dev/disk/by-label/nixcrypt";
      allowDiscards = true;
    };
  };

  fileSystems = {
    "/" = rootSubvol "@nixos/@root";
    "/nix" = rootSubvol "@nix";
    "/home" = rootSubvol "@nixos/@home";
    "/var/lib" = rootSubvol "@nixos/@var/lib";
    "/var/log" = rootSubvol "@nixos/@var/log";

    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-label/nixswap";}
  ];
}
