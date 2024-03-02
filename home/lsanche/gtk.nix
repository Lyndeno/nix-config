{
  pkgs,
  lib,
  isDesktop,
  isGnome,
}: {
  enable = lib.mkDefault (isDesktop && isGnome);
  #theme.name = "Adwaita-dark";
  #theme.package = pkgs.gnome.gnome-themes-extra;
  iconTheme.name = "Papirus-Dark";
  iconTheme.package = pkgs.papirus-icon-theme;
}
