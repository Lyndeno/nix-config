{
  inputs,
  super,
}:
with inputs.nixos-hardware.nixosModules; [
  inputs.disko.nixosModules.disko
  inputs.lanzaboote.nixosModules.lanzaboote
  super.intelModule
]
