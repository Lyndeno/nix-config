_lib: inputs: commonModules:
with inputs.nixos-hardware.nixosModules;
  [
    ./configuration.nix
    ./hardware.nix
    ./disks.nix
    common-gpu-amd
    common-cpu-amd
    common-cpu-amd-pstate
    inputs.lanzaboote.nixosModules.lanzaboote
    ({lib, ...}: {
      boot = {
        loader.systemd-boot.enable = lib.mkForce false;
        lanzaboote = {
          enable = true;
          pkiBundle = "/etc/secureboot";
          settings = {
            console-mode = "max";
            timeout = 0;
          };
        };
      };
    })
  ]
  ++ commonModules
