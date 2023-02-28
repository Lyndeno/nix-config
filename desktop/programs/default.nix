{config, lib, pkgs, inputs, ...}: {
  config = lib.mkIf config.ls.desktop.enable (lib.mkMerge [
    (import ./vscode { inherit config lib pkgs inputs; })
    (import ./alacritty.nix{ inherit config pkgs inputs; })
    #(import ./emacs.nix { inherit config pkgs inputs; })
    (import ./browser.nix { inherit config lib pkgs inputs; })
    (import ./mangohud.nix { inherit config lib pkgs inputs; })
    #(import ./email.nix { inherit config lib pkgs inputs; })
    (import ./gtk.nix { inherit config lib pkgs inputs; })
    (import ./firefox.nix { inherit config lib pkgs inputs; })
    (import ./misc.nix { inherit config lib pkgs inputs; })
  ]);
}
