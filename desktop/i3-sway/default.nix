{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    (import ./sway.nix {inherit config lib pkgs inputs;})
    (import ./i3.nix {inherit config lib pkgs inputs;})
  ];
}
