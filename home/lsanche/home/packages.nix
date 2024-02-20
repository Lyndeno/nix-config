{
  pkgs,
  lib,
  isDesktop,
  inputs,
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
    inputs.bbase.packages.${system}.default

    # Email
    #thunderbird
    wally-cli # for moonlander

    # media
    spotify
    #spot
    fragments
    celluloid
    inkscape
    gimp
    darktable
    kdiskmark

    # Office
    libreoffice
    kicad
    zathura
    imv
    denaro
  ])
