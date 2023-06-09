{config, ...}: {
  boot.initrd.availableKernelModules = ["nvme" "mpt3sas" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.kernelModules = ["kvm-amd" "jc42" "nct6775"];
  boot.kernelParams = [
    "quiet"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
  ];
  boot.consoleLogLevel = 3;

  zramSwap.enable = true;

  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
}
