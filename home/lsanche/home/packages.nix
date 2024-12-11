{
  pkgs,
  lib,
  osConfig,
}:
with osConfig.mods; let
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
      #signal-desktop
      #discord
      slack

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
      thunderbird
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
    ])
    ++ (lib.lists.optionals isGnome [
      libreoffice
      hunspellDicts.en_CA
      #denaro

      #spot
      fragments
      celluloid

      fractal
    ])
    ++ (lib.lists.optionals isPlasma [
      libreoffice-qt
    ])
