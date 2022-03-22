{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  fileSystems = {
	  "/" = {
      device = "/dev/nixpool/nixroot";
      fsType = "ext4";
	  };

	  "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    "/data/mirror" = {
      device = "/dev/disk/by-label/mirrorpool";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd:6" ];
    };
  };

  swapDevices =
    [ { device = "/dev/nixpool/nixswap"; }
    ];
}
