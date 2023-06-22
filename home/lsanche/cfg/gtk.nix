{
  pkgs,
  lib,
  isDesktop,
}: {
  enable = lib.mkDefault isDesktop;
  #theme.name = "Adwaita-dark";
  #theme.package = pkgs.gnome.gnome-themes-extra;
  iconTheme.name = "Papirus-Dark";
  iconTheme.package = pkgs.papirus-icon-theme;
}
