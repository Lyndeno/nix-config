{
  pkgs,
  lib,
  isDesktop,
}:
with pkgs;
  [
    neofetch
  ]
  ++ (lib.lists.optionals isDesktop [
    # Communication
    signal-desktop
    discord
    element-desktop
    giara
    fractal

    # Development
    nil
    clang-tools
    bear
    lldb
    clippy
    rustfmt

    # Email
    thunderbird

    # media
    spotify
    spot
    fragments
    celluloid

    # Office
    libreoffice-qt
    kicad
    zathura
    imv
  ])
