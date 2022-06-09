{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  #boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [
  #  "i915.enable_fbc=1"
  #  "i915.enable_psr=2"
    "acpi_rev_override=1"
  ];
  #boot.extraModprobeConfig = "options nouveau modeset=0";
  hardware.enableRedistributableFirmware = true;
  #hardware.cpu.intel.updateMicrocode = true;
  hardware.bluetooth.enable = true;

  #services.udev.extraRules = ''
  #  # Remove NVIDIA USB xHCI Host Controller devices, if present
  #  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

  #  # Remove NVIDIA USB Type-C UCSI devices, if present
  #  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

  #  # Remove NVIDIA Audio devices, if present
  #  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

  #  # Remove NVIDIA VGA/3D controller devices
  #  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  #'';

  services.lvm.boot.thin.enable = true;

  boot.initrd.luks.devices = {
    "nixcrypt" = {
      preLVM = true;
      device = "/dev/disk/by-label/nixcrypt";
    };
  };

  # Graphics
  #services.xserver.videoDrivers = [ "modesetting" ];
  #services.xserver.useGlamor = true;
  #hardware.opengl.extraPackages = with pkgs; [
  #  intel-compute-runtime
  #  vaapiIntel
  #  vaapiVdpau
  #  libvdpau-va-gl
  #];
  #hardware.opengl.driSupport = true;

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
