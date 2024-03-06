{inputs}:
with inputs.nixos-hardware.nixosModules; [
  common-cpu-intel-kaby-lake
  inputs.disko.nixosModules.disko
  inputs.lanzaboote.nixosModules.lanzaboote
  ./_disko.nix
]
