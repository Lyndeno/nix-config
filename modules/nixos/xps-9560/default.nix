# meta.description = "Dell XPS 15 9560 hardware support"
{inputs, ...}: let
  intelModule = "${inputs.nixos-hardware}/dell/xps/15-9560/intel";
in {
  imports = [
    intelModule
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];
  specialisation = {
    nvidia = {
      configuration = {config, ...}: {
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
          # Preserve VRAM across suspend; without this the compositor resumes
          # to a GPU full of garbage (NVRM Xid 13) and the machine hangs.
          powerManagement.enable = true;
        };
        # nixpkgs only orders the nvidia-{suspend,resume} units around
        # systemd-suspend/hibernate.service, but the lid uses
        # suspend-then-hibernate (see the laptop module), which never starts
        # those. Order them around it too, and install the driver's
        # system-sleep hook for the hibernate phase.
        systemd.services = let
          sth = "systemd-suspend-then-hibernate.service";
        in {
          nvidia-suspend = {
            before = [sth];
            requiredBy = [sth];
          };
          nvidia-resume = {
            after = [sth];
            requiredBy = [sth];
          };
        };
        environment.etc."systemd/system-sleep/nvidia".source = "${config.hardware.nvidia.package}/lib/systemd/system-sleep/nvidia";
        # Make niri composite on the dGPU; the iGPU only scans out the panel.
        # Bus ID matches hardware.nvidia.prime.nvidiaBusId (PCI:1:0:0).
        home-manager.users.lsanche.programs.niri.includeFiles = [./niri-nvidia.kdl];
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
    extraModprobeConfig = ''
      options iwlwifi power_save=1
      options iwlmvm power_scheme=3
    '';
  };
}
