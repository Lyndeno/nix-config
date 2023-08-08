{
  pkgs,
  lib,
  isDesktop,
}:
with pkgs;
  [
    neofetch
    nix-output-monitor
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

    newsflash

    # Development
    nil
    clang-tools
    bear
    lldb
    clippy
    rustfmt
    octaveFull

    # Email
    #thunderbird

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
    denaro
  ])
