{
  pkgs,
  lib,
  inputs,
  osConfig,
}:
with osConfig.mods; let
  isDesktop = desktop.enable;
  isGnome = gnome.enable;
  isPlasma = plasma.enable;
in
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

      # Development
      nixd
      rust-analyzer
      texlab
      clang-tools
      bear
      lldb
      clippy
      rustfmt
      inputs.bbase.packages.${system}.default

      # Email
      wally-cli # for moonlander

      # media
      spotify
      #inkscape
      gimp
      #darktable

      # Office
      #kicad
      #octaveFull
      #zathura
      #imv
      joplin-desktop
    ])
    ++ (lib.lists.optionals isGnome [
      libreoffice
      #denaro

      #spot
      fragments
      celluloid

      fractal
    ])
    ++ (lib.lists.optionals isPlasma [
      libreoffice-qt
    ])
