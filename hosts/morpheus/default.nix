_lib: inputs: commonModules:
with inputs.nixos-hardware.nixosModules;
  [
    ./configuration.nix
    ./hardware.nix
    ./vm.nix
    ./disks.nix
    common-gpu-amd
    common-cpu-amd
    common-cpu-amd-pstate
  ]
  ++ commonModules
