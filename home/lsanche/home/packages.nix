{
  pkgs,
  lib,
  isDesktop,
  isGnome,
  isPlasma,
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
    slack
    #element-desktop

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
    inkscape
    gimp
    darktable
    kdiskmark

    # Office
    kicad
    #zathura
    #imv
  ])
  ++ (lib.lists.optionals isGnome [
    libreoffice
    denaro

    #spot
    fragments
    celluloid

    giara
    fractal
    #fractal-next
    #flare-signal

    newsflash
  ])
  ++ (lib.lists.optionals isPlasma [
    libreoffice-qt
  ])
