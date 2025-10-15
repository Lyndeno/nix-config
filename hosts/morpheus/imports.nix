{inputs}:
with inputs.nixos-hardware.nixosModules; [
  common-gpu-amd
  common-cpu-amd
  common-cpu-amd-pstate
  common-pc-ssd
  inputs.nixarr.nixosModules.default
]
