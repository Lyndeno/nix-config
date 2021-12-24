# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

let
	rootSubvol = subvol:
	{
		device = "/dev/disk/by-uuid/7a780716-8ad8-4fbf-b3d1-75667dd1b9e6";
		fsType = "btrfs";
		options = [ "noatime" "compress=zstd" "subvol=${subvol}" ];
	};
in
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

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
	"cryptkey" = {
		device = "/dev/disk/by-uuid/dff20566-4abd-47c5-8d37-6fef507d0fc9";
	};
	"cryptswap" = {
		device = "/dev/disk/by-uuid/c374e43b-6656-4ba7-b615-ba60819cae59";
		keyFile = "/dev/mapper/cryptkey";
	};
	"cryptroot" = {
		device = "/dev/disk/by-uuid/dae4aaa7-27ab-4f9b-8316-3f7355b7b712";
		keyFile = "/dev/mapper/cryptkey";
	};
  };

  # Graphics
  services.xserver.videoDrivers = [ "modesetting" ];
  #hardware.nvidia.modesetting.enable = true;
  services.xserver.useGlamor = true;
  hardware.opengl.extraPackages = with pkgs; [
    intel-compute-runtime
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];
  hardware.opengl.driSupport = true;

  #hardware.nvidia.prime = {
  #  offload.enable = true;
  #  intelBusId = "PCI:0:2:0";
  #  nvidiaBusId = "PCI:1:0:0";
  #};

  fileSystems = {
	  "/" = {
		device = "none";
		fsType = "tmpfs";
	  };
	  "/home" = rootSubvol "persist/home";
	  "/root" = rootSubvol "persist/home/root";
	  "/nix" = rootSubvol "persist/nix";
	  "/etc/nixos" = (pkgs.lib.mkMerge [
		(rootSubvol "persist/etc/nixos")
		({neededForBoot = true;})
	  ]);
	  "/etc/NetworkManager/system-connections" = rootSubvol "persist/etc/NetworkManager/system-connections";
	  "/var/log" = rootSubvol "persist/var/log";
	  "/boot" =
	    {
	      device = "/dev/disk/by-uuid/D848-76E8";
	      fsType = "vfat";
	    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/f27de7bd-8ac2-49a4-9c55-51f717cea458"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
