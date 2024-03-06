{inputs}: let
  # deadnix: skip
  loadFolder = folder: ({pkgs, ...} @ args:
    inputs.haumea.lib.load {
      src = folder;
      inputs = args;
      transformer = inputs.haumea.lib.transformers.liftDefault;
    });

  hostCommon = loadFolder ./_common;
  common = loadFolder ../../common;
in {
  imports = [
    inputs.nixos-hardware.nixosModules.dell-xps-15-9560-intel
    hostCommon
  ];

  specialisation.nvidia = {
    inheritParentConfig = false;
    configuration = {
      imports = [
        inputs.nixos-hardware.nixosModules.dell-xps-15-9560-nvidia
        hostCommon
        # this is not automatically imported since we do not inherit base config
        common
        {
          services.switcherooControl.enable = true;
          hardware.nvidia.modesetting.enable = true;
          networking.hostName = "neo";
        }
      ];
    };
  };
}
