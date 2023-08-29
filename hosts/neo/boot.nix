{
  lib,
  pkgs,
}: {
  # See Arch wiki bug bugs.archlinux.org/task/79439
  blacklistedKernelModules = lib.warn "Temporary fix for laptop" [
    "rtsx_pci"
    "rtsx_pci_sdmmc"
  ];
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
  plymouth = {
    enable = true;
  };
  kernelParams = [
    "acpi_rev_override=1" # nvidia card crashes things without this
    "intel_iommu=on"
    "iommu=pt"
    "quiet"
    #"log_level=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
  ];
  kernelModules = [
    "coretemp" # sensors-detect for Intel temperature
  ];
  consoleLogLevel = 3;
  kernelPackages = pkgs.linuxPackages_latest;

  binfmt.emulatedSystems = ["aarch64-linux"];
}
