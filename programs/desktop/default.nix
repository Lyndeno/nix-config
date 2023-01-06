{config, lib, pkgs, inputs, ...}: {
  config = lib.mkIf config.ls.desktop.enable (lib.mkMerge [
    (import ./vscode { inherit config lib pkgs inputs; })
    (import ./alacritty.nix{ inherit config pkgs inputs; })
    (import ./emacs.nix{ inherit config pkgs inputs; })
  ]);
}