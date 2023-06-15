lib: inputs: commonModules:
with inputs.nixos-hardware.nixosModules; let
  # deadnix: skip
  cfg = {pkgs, ...} @ args:
    inputs.haumea.lib.load {
      src = ./cfg;
      inputs =
        args
        // {
          inherit (inputs.nixpkgs) lib;
        };
      transformer = [
        inputs.haumea.lib.transformers.liftDefault
        (inputs.haumea.lib.transformers.hoistLists "_imports" "imports")
      ];
    };
in
  [
    cfg
    dell-xps-15-9560-intel
    common-cpu-intel-kaby-lake
    #({hostName, ...}: {
    #  specialisation.nvidia = {
    #    inheritParentConfig = false;
    #    configuration = {
    #      imports =
    #        [
    #          cfg
    #          ./disko.nix
    #          inputs.lanzaboote.nixosModules.lanzaboote
    #          inputs.nixos-hardware.nixosModules.dell-xps-15-9560-nvidia
    #          inputs.nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
    #          inputs.disko.nixosModules.disko
    #        ]
    #        ++ commonModules;

    #      services.xserver.videoDrivers = lib.mkForce ["nvidia"];
    #      services.switcherooControl.enable = true;
    #      networking.hostName = hostName;
    #      system.stateVersion = "23.05";
    #      hardware.nvidia = {
    #        modesetting.enable = true;
    #      };
    #    };
    #  };
    #})
  ]
  ++ commonModules
