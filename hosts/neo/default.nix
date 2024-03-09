{
  inputs,
  super,
}: let
  hostCommon = super.common;
  intelModule = "${inputs.nixos-hardware}/dell/xps/15-9560/intel";
in {
  imports = [
    intelModule
    hostCommon
  ];

  specialisation.nvidia = {
    configuration = {
      imports = [
        inputs.nixos-hardware.nixosModules.dell-xps-15-9560-nvidia
      ];

      disabledModules = [
        intelModule
      ];
      services.switcherooControl.enable = true;
      hardware.nvidia.modesetting.enable = true;
      networking.hostName = "neo";
    };
  };
}
