{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  args = {inherit config lib pkgs inputs;};
in {
  config = lib.mkIf config.ls.desktop.enable (lib.mkMerge [
    (import ./vscode args)
    (import ./alacritty.nix args)
    #(import ./emacs.nix { inherit config pkgs inputs; })
    (import ./browser.nix args)
    (import ./mangohud.nix args)
    #(import ./email.nix { inherit config lib pkgs inputs; })
    (import ./gtk.nix args)
    (import ./firefox.nix args)
    (import ./misc.nix args)
  ]);
}
