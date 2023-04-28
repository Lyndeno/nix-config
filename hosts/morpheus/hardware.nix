{config, ...}: {
  boot.initrd.availableKernelModules = ["nvme" "mpt3sas" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.kernelModules = ["kvm-amd" "jc42" "nct6775"];

  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
}
