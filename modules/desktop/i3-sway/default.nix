{config, lib, pkgs, defaultFont, inputs, ...}:
{
  imports = [
    ( import ./sway.nix {inherit config lib pkgs defaultFont inputs; } )
    ( import ./i3.nix {inherit config lib pkgs defaultFont inputs; } ) 
  ];
}
