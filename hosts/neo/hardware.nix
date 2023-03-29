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
      ];
    };
    kernelParams = [
      "acpi_rev_override=1" # nvidia card crashes things without this
      "pcie_aspm=off"
    ];
    kernelModules = [
      "coretemp" # sensors-detect for Intel temperature
    ];
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.thermald.enable = false;

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
