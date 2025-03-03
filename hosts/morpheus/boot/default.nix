{config}: {
  kernelModules = ["kvm-amd" "jc42" "nct6775" "ddcci" "sg"];
  swraid.enable = false;

  extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
}
