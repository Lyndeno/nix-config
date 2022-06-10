{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "acpi_rev_override=1"
  ];
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;

  services.lvm.boot.thin.enable = true;

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
      options = [ "discard" ];
	  };
	  "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-label/nixswap"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
