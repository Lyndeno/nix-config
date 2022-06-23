{ config, pkgs, inputs, ... }:
{
  home-manager.users.lsanche.programs.emacs = {
    enable = true;
    extraPackages = epkgs: [ epkgs.evil epkgs.base16-theme];
    extraConfig = ''
      (require 'evil)
      (evil-mode 1)
    '';
  };
}
