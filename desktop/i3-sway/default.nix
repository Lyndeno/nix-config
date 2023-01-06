{config, lib, pkgs, defaults, inputs, ...}:
{
  imports = [
    ( import ./sway.nix {inherit config lib pkgs defaults inputs; } )
    ( import ./i3.nix {inherit config lib pkgs defaults inputs; } ) 
  ];
}
