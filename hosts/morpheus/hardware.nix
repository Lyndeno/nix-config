{config, ...}: {
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
}
