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
    fractal-next
    flare-signal
    health

    # Development
    nil
    clang-tools
    bear
    lldb
    clippy
    rustfmt
    octaveFull

    # Email
    thunderbird

    # media
    spotify
    spot
    fragments
    celluloid
    inkscape
    gimp

    # Office
    libreoffice
    kicad
    zathura
    imv
  ])
