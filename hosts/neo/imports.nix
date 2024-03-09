{
  inputs,
  super,
}:
with inputs.nixos-hardware.nixosModules; [
  common-cpu-intel-kaby-lake
  inputs.disko.nixosModules.disko
  inputs.lanzaboote.nixosModules.lanzaboote
  super.disko
  super.intelModule
]
