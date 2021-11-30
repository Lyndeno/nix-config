# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

let
	rootSubvol = subvol:
	{
		device = "/dev/disk/by-uuid/497703c2-53ab-4f72-9bd2-8ec393ea5315";
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
  ];
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  boot.initrd.luks.devices = {
	cryptkey = {
		device = "/dev/disk/by-uuid/7513bec7-f195-4e13-ba7a-c74732a2a35b"; 
	};
	cryptroot = {
		device = "/dev/disk/by-uuid/0d0f9284-2728-442a-8fc2-e77f28cad680"; 
		keyFile = "/dev/mapper/cryptkey";
	};
	cryptswap = {
		device = "/dev/disk/by-uuid/662a5eb0-54de-4c01-bcff-9bca0b9a9d23"; 
		keyFile = "/dev/mapper/cryptkey";
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
	  "/" = rootSubvol "root";
	  "/home" = rootSubvol "home";
	  "/root" = rootSubvol "home/root";
	  "/nix" = rootSubvol "nix";
	  "/var/log" = rootSubvol "log";
	  "/srv/torrents" = rootSubvol "torrents";
	  "/boot" =
	    {
	      device = "/dev/disk/by-uuid/6BB6-C135";
	      fsType = "vfat";
	    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/973ffeac-00cc-46f3-a64c-bd4416334693"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
