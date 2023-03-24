{pkgs, ...}: {
  home-manager.users.lsanche.programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
    extraPackages = epkgs: [epkgs.evil epkgs.base16-theme];
    extraConfig = ''
      (require 'evil)
      (evil-mode 1)
    '';
  };
}
