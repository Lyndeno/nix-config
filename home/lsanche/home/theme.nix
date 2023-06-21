{pkgs, ...}: {
  stylix.targets = {
    swaylock.useImage = false;
  };
  stylix.opacity = {
    terminal = 0.95;
  };
  gtk = {
    enable = true;
    #theme.name = "Adwaita-dark";
    #theme.package = pkgs.gnome.gnome-themes-extra;
    iconTheme.name = "Papirus-Dark";
    iconTheme.package = pkgs.papirus-icon-theme;
  };
}
