{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_rpi4; # Raspberry pies have a hard time booting on the LTS kernel.
  boot = {
    tmp.useTmpfs = true;
    initrd.availableKernelModules = ["usbhid" "usb_storage"];
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyS0,115200"
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
    "/data/borg" = {
      device = "/dev/disk/by-label/omicron";
      fsType = "btrfs";
      options = ["noatime" "compress=zstd:6" "subvolid=256"];
    };
  };

  hardware.enableRedistributableFirmware = true;
}
