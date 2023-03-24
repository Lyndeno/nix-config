lib: inputs: commonModules:
with inputs.nixos-hardware.nixosModules;
  [
    ./configuration.nix
    ./hardware.nix
    ./disks.nix
    dell-xps-15-9560-intel
    common-cpu-intel-kaby-lake
    (_: {
      specialisation.nvidia = {
        inheritParentConfig = false;
        configuration = {
          imports =
            [
              ./configuration.nix
              ./hardware.nix
              inputs.nixos-hardware.nixosModules.dell-xps-15-9560-nvidia
              inputs.nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
            ]
            ++ commonModules;

          ls.desktop.environment = lib.mkForce "gnome";
          services.xserver.videoDrivers = lib.mkForce ["nvidia"];
          services.switcherooControl.enable = true;
          hardware.nvidia = {
            modesetting.enable = true;
          };
        };
      };
    })
  ]
  ++ commonModules
