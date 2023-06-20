{
  pkgs,
  lib,
  isDesktop,
  ...
}: {
  stylix.targets = lib.mkIf isDesktop {
    swaylock.useImage = false;
  };
  stylix.opacity = {
    terminal = 0.95;
  };
  gtk = lib.mkIf isDesktop {
    enable = true;
    #theme.name = "Adwaita-dark";
    #theme.package = pkgs.gnome.gnome-themes-extra;
    iconTheme.name = "Papirus-Dark";
    iconTheme.package = pkgs.papirus-icon-theme;
  };
}
