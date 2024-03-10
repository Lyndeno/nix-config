{
  pkgs,
  lib,
  osConfig,
}: {
  enable = with osConfig.mods; lib.mkDefault (desktop.enable && gnome.enable);
  #theme.name = "Adwaita-dark";
  #theme.package = pkgs.gnome.gnome-themes-extra;
  iconTheme.name = "Papirus-Dark";
  iconTheme.package = pkgs.papirus-icon-theme;
}
