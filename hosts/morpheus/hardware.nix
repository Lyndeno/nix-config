{config, ...}: {
  boot.kernelModules = ["kvm-amd" "jc42" "nct6775" "ddcci"];
  boot.kernelParams = [
    "quiet"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "iommu=pt"
  ];
  boot.extraModulePackages = [config.boot.kernelPackages.ddcci-driver];

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
}
