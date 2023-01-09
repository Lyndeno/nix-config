{config, pkgs, lib, inputs}:
{
  home-manager.users.lsanche = {

    home.packages = with pkgs; [
        spotify
        zathura
        signal-desktop
        spotify
        discord
        libreoffice-qt
        imv
        element-desktop
    ];

  };
}