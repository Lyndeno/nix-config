{pkgs}: {
  enableRedistributableFirmware = true;
  bluetooth.enable = true;
  graphics.extraPackages = [pkgs.intel-compute-runtime];
}
