{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages; # Raspberry pies have a hard time booting on the LTS kernel.
  boot = {
    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      "cma=128M"
    ];
  };

  #boot.loader.raspberryPi = {
  #  enable = true;
  #  version = 4;
  #};
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.grub.enable = false;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  hardware.enableRedistributableFirmware = true;
}

