{
  inputs,
  flake,
}:
with inputs.nixos-hardware.nixosModules; [
  common-gpu-amd
  common-cpu-amd
  common-cpu-amd-pstate
  common-pc-ssd
  flake.modules.nixos.common
  flake.modules.nixos.virtualisation
  flake.modules.nixos.zed
  flake.modules.nixos.gaming
  flake.modules.nixos.desktop
  flake.modules.nixos.gnome
  flake.modules.nixos.secureboot
]
