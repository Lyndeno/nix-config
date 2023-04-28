_lib: inputs: commonModules:
[
  ./configuration.nix
  ./hardware.nix
  ./vm.nix
  ./disks.nix
  inputs.nixos-hardware.nixosModules.common-gpu-amd
]
++ commonModules
