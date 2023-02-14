{config, pkgs, lib, inputs}:
{
  home-manager.users.lsanche = {

    home.packages = with pkgs; [
        spotify
        signal-desktop
        spotify
        discord
        libreoffice-qt
        element-desktop
        kicad
    ];

  };
}
