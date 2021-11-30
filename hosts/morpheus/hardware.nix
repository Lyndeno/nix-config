# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:
let
	rootSubvol = subvol:
	{
		device = "/dev/disk/by-uuid/545b7cd0-e18b-494c-8d26-1ee1392db5ab";
		fsType = "btrfs";
		options = [ "noatime" "compress=zstd" "subvol=${subvol}" ];
	};
in
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = rootSubvol "root";
    "/home" = rootSubvol "home";
    "/root" = rootSubvol "home/root";
    "/nix" = rootSubvol "nix";
    "/var/log" = rootSubvol "log";
    "/srv/torrents" = rootSubvol "torrents";
    "/srv/plex" = rootSubvol "plex";
    "/boot" =
        { device = "/dev/disk/by-uuid/3F5E-1123";
          fsType = "vfat";
        };
    "/data/mirror" = 
      {
        device = "/dev/disk/by-uuid/155d647d-ca6e-4b08-8c88-9cc2a49c9a5d";
        fsType = "btrfs";
        options = [ "noatime" "compress=zstd" "subvol=@toplevel" ];
      };
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/4171064c-a4f5-4233-baee-c9de03c2df81"; }
    ];

}
