{config}: {
  consoleLogLevel = 3;
  kernelModules = ["kvm-amd" "jc42" "nct6775" "ddcci"];
  kernelParams = [
    "quiet"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "iommu=pt"
  ];
  swraid.enable = false;

  kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
}
