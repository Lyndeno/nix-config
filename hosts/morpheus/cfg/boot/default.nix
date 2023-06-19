{
  config,
  lib,
}: {
  consoleLogLevel = 3;
  kernelModules = ["kvm-amd" "jc42" "nct6775" "ddcci"];
  kernelParams = [
    "quiet"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "iommu=pt"
  ];

  # FIXME: For some reason mkForce is needed to prevent infinite recursion
  kernelPackages = lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;
  extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
}
