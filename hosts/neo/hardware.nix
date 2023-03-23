{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  rootSubvol = subvol: {
    device = "/dev/disk/by-label/linuxdata";
    fsType = "btrfs";
    options = ["noatime" "compress=zstd" "subvol=${subvol}" "discard=async"];
  };
in {
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      kernelModules = [
        "kvm-intel"
      ];
    };
    kernelParams = [
      "acpi_rev_override=1" # nvidia card crashes things without this
    ];
    kernelModules = [
      "coretemp" # sensors-detect for Intel temperature
    ];
  };

  services.lvm.boot.thin.enable = true;

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
  };

  boot.initrd.luks.devices = {
    "nixcrypt" = {
      preLVM = true;
      device = "/dev/disk/by-label/nixcrypt";
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

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
