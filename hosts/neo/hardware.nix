{ config, lib, pkgs, modulesPath, ... }:

{

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
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

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
  };

  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "54c50fe2";
  boot.zfs.allowHibernation = true;

  boot.initrd.luks.devices = {
    "nixboot" = {
      device = "/dev/disk/by-uuid/a29e226a-810e-48fa-932e-03569767185e";
      keyFile = "/secrets/nixkey";
    };
    "nixswap" = {
      device = "/dev/disk/by-label/cryptswap";
      keyFile = "/secrets/nixkey";
    };
  };

  boot.initrd = {
    secrets = {
      "/secrets/nixkey" = "/secrets/nixkey";
    };
  };

  fileSystems = {
  "/" =
    { device = "nixpool/nixos/root";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  "/home" =
    { device = "nixpool/nixos/home";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  "/var/lib" =
    { device = "nixpool/nixos/var/lib";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  "/var/log" =
    { device = "nixpool/nixos/var/log";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  "/boot" =
    { device = "/dev/disk/by-label/nixboot";
      fsType = "ext4";
    };
  "/boot/efi" =
    { device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-label/nixswap"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
