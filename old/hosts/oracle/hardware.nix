{
  lib,
  config,
}: {
  cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
