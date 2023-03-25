{
  pkgs,
  lib,
  isDesktop,
  ...
}: {
  home.packages = with pkgs;
    lib.mkIf isDesktop [
      libreoffice-qt
      kicad
      zathura
      imv
    ];
}
