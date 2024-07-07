{lib}: {
  swraid.enable = false;
  loader = {
    systemd-boot.enable = lib.mkForce false;
    grub.enable = lib.mkForce false;
    timeout = 0;
    efi.canTouchEfiVariables = true;
  };
  lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
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
  kernelPatches = [
    {
      name = "dell-platform-profile";
      patch = ./dell_pp.patch;
    }
  ];

  binfmt.emulatedSystems = ["aarch64-linux"];
}
