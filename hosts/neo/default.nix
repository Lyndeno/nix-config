{
  inputs,
  lsLib,
  lib,
}: let
  multinix = import ../../multinix {
    haumea = inputs.haumea;
    inherit lib lsLib;
  };

  inherit (multinix) loadFolder;

  hostCommon = loadFolder ./_common;
  common = loadFolder ../../common;

  # FIXME: This is a hack
  mods = import ../../multinix/modules.nix {
    inherit lsLib loadFolder;
    modFolder = ../../mods;
  };
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
        mods
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
