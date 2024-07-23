{
  inputs,
  super,
}:
with inputs.nixos-hardware.nixosModules; [
  common-gpu-intel-kaby-lake
  inputs.disko.nixosModules.disko
  inputs.lanzaboote.nixosModules.lanzaboote
  super.intelModule
]
