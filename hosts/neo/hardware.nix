{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      kernelModules = [
        "kvm-intel"
        "dm-snapshot"
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
    "/" = {
      device = "/dev/disk/by-label/nixroot";
      fsType = "ext4";
      options = ["discard" "noatime"];
    };

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
