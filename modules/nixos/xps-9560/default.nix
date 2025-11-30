{inputs, ...}: let
  intelModule = "${inputs.nixos-hardware}/dell/xps/15-9560/intel";
in {
  imports = [
    intelModule
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];
  specialisation = {
    nvidia = {
      configuration = {
        imports = [
          inputs.nixos-hardware.nixosModules.dell-xps-15-9560-nvidia
        ];

        disabledModules = [
          intelModule
        ];
        hardware.nvidia = {
          modesetting.enable = true;
          open = false;
          nvidiaSettings = false;
        };
        # For nh
        environment.etc."specialisation".text = "nvidia";
      };
    };
  };

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      kernelModules = [
        "kvm-intel"
        "tpm_tis"
      ];
    };
    kernelParams = [
      "intel_iommu=on"
    ];
    kernelModules = [
      "coretemp" # sensors-detect for Intel temperature
    ];
  };
}
