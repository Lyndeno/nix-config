{
  systemd.enable = true;

  luks.devices."cryptroot" = {
    device = "/dev/disk/by-label/nixcrypt";
    bypassWorkqueues = true;
    allowDiscards = true;
  };

  availableKernelModules = ["nvme" "mpt3sas" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
}
