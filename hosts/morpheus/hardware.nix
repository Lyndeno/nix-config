{config, ...}: {
  boot.extraModulePackages = [config.boot.kernelPackages.ddcci-driver];

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
}
