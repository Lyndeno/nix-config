{
  pkgs,
  lib,
}: {
  enableRedistributableFirmware = true;
  bluetooth.enable = true;
  opengl.extraPackages = lib.warn "Upstream this to nixos-hardware" [pkgs.intel-compute-runtime];
}
