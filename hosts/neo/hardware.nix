{ config, lib, pkgs, modulesPath, ... }:

{

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [
        "kvm-intel"
        "dm-snapshot" # booting off lvm-thin
      ];
    };
    kernelParams = [
      "acpi_rev_override=1" # nvidia card crashes things without this
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
      options = [ "discard" ]; # discard to make sure thin volume only uses needed space
	  };
	  "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
    "/data/omicron" = {
      device = "/dev/disk/by-label/omicron";
      fsType = "ext4";
      options = [ "noauto" "x-gvfs-show" ];
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-label/nixswap"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
