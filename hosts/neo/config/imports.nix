{
  inputs,
  super,
  flake,
}:
with inputs.nixos-hardware.nixosModules; [
  inputs.disko.nixosModules.disko
  super.intelModule
  common-pc-laptop-ssd
  flake.modules.nixos.common
  flake.modules.nixos.virtualisation
  flake.modules.nixos.desktop
  flake.modules.nixos.gnome
  flake.modules.nixos.hydraCache
  flake.modules.nixos.niri
  flake.modules.nixos.secureboot
  flake.modules.nixos.laptop
]
