{config, pkgs, lib, inputs}:
{
  home-manager.users.lsanche = {
    gtk = {
        enable = true;
        theme.name = "Adwaita-dark";
        theme.package = pkgs.gnome.gnome-themes-extra;
        iconTheme.name = "Papirus-Dark";
        iconTheme.package = pkgs.papirus-icon-theme;
    };
  };
}