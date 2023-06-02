{
  pkgs,
  lib,
  ...
}: {
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      kernelModules = [
        "kvm-intel"
        "tpm_tis"
      ];
    };
    kernelParams = [
      "acpi_rev_override=1" # nvidia card crashes things without this
      "intel_iommu=on"
      "iommu=pt"
      "quiet"
    ];
    kernelModules = [
      "coretemp" # sensors-detect for Intel temperature
    ];
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.thermald.enable = false;
  security.tpm2.enable = true;

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
