{
  config,
  lib,
  ...
}: {
  boot.initrd.availableKernelModules = ["nvme" "mpt3sas" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.kernelModules = ["kvm-amd" "jc42" "nct6775" "ddcci"];
  boot.kernelParams = [
    "quiet"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "iommu=pt"
  ];
  boot.consoleLogLevel = 3;
  boot.extraModulePackages = [config.boot.kernelPackages.ddcci-driver];

  hardware.enableRedistributableFirmware = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
}
