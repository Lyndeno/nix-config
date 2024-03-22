{config}: {
  kernelModules = ["kvm-amd" "jc42" "nct6775" "ddcci"];
  kernelParams = [
    "iommu=pt"
  ];
  swraid.enable = false;

  kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
}
