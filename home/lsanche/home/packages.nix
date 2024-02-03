{
  pkgs,
  lib,
  isDesktop,
}:
with pkgs;
  [
    neofetch
    nix-output-monitor
    ocrmypdf
  ]
  ++ (lib.lists.optionals isDesktop [
    # Communication
    #signal-desktop
    discord
    #element-desktop
    giara
    fractal
    #fractal-next
    #flare-signal

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
    #spot
    fragments
    celluloid
    inkscape
    gimp
    darktable

    # Office
    libreoffice
    kicad
    zathura
    imv
    denaro
  ])
