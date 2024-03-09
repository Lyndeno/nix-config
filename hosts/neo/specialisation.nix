{
  inputs,
  super,
}: {
  nvidia = {
    configuration = {
      imports = [
        inputs.nixos-hardware.nixosModules.dell-xps-15-9560-nvidia
      ];

      disabledModules = [
        super.intelModule
      ];
      services.switcherooControl.enable = true;
      hardware.nvidia.modesetting.enable = true;
      networking.hostName = "neo";
    };
  };
}
