{
  pkgs,
  lib,
  osConfig,
}:
with osConfig.modules; let
  isDesktop = desktop.enable;
  isGnome = gnome.enable;
  isPlasma = plasma.enable;
in
  with pkgs;
    [
      nix-output-monitor
      #ocrmypdf
      nixpkgs-review
      nh
    ]
    ++ (lib.lists.optionals isDesktop [
      # Communication
      slack

      wally-cli # for moonlander

      # media
      inkscape
      gimp
      darktable

      # Office
      kicad
      octaveFull
      #zathura
      #imv
      joplin-desktop

      # Development
      nixd
      rust-analyzer
      texlab
      clang-tools
      bear
      lldb
      clippy
      rustfmt

      hunspellDicts.en_CA
    ])
    ++ (lib.lists.optionals isGnome [
      libreoffice

      fragments
      celluloid

      fractal
    ])
    ++ (lib.lists.optionals isPlasma [
      libreoffice-qt
    ])
