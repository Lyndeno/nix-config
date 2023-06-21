{pkgs, ...}: {
  home.packages = with pkgs; [
    libreoffice-qt
    kicad
    zathura
    imv
  ];
}
