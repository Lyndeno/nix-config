{config}: {
  swraid.enable = false;
  initrd = {
    systemd = {
      enable = true;
    };
    availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
    kernelModules = [
      "kvm-intel"
      "tpm_tis"
    ];
  };
  kernelParams = [
    "acpi_rev_override=1" # nvidia card crashes things without this
    "intel_iommu=on"
  ];
  kernelModules = [
    "coretemp" # sensors-detect for Intel temperature
  ];
  binfmt.emulatedSystems = ["aarch64-linux"];
  extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
}
