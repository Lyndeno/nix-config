{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "i915.enable_fbc=1"
    "i915.enable_psr=2"
    "acpi_rev_override=1"
  ];
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  boot.initrd.luks.devices = {
    "nixcrypt" = {
      preLVM = true;
      device = "/dev/disk/by-label/nixcrypt";
    };
  };

  # Graphics
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.useGlamor = true;
  hardware.opengl.extraPackages = with pkgs; [
    intel-compute-runtime
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];
  hardware.opengl.driSupport = true;

  fileSystems = {
	  "/" = {
      device = "/dev/nixpool/nixroot";
      fsType = "ext4";
	  };
	  "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  swapDevices =
    [ { device = "/dev/nixpool/nixswap"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
