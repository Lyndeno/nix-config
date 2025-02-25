{
  inputs,
  super,
}:
with inputs.nixos-hardware.nixosModules; [
  inputs.disko.nixosModules.disko
  super.intelModule
  common-pc-laptop-ssd
]
