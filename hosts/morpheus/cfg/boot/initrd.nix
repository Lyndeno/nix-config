{
  systemd.enable = true;

  luks.devices."cryptroot".device = "/dev/disk/by-label/nixcrypt";

  availableKernelModules = ["nvme" "mpt3sas" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
}
