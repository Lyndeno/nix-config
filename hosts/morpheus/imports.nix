{inputs}:
with inputs.nixos-hardware.nixosModules; [
  common-gpu-amd
  common-cpu-amd
  common-cpu-amd-pstate
  inputs.lanzaboote.nixosModules.lanzaboote
]
