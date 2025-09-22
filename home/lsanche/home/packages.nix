{
  pkgs,
  lib,
  osConfig,
}:
with osConfig.modules; let
  isDesktop = desktop.enable;
  isGnome = gnome.enable;
  isNiri = niri.enable;
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

      #wally-cli # for moonlander
      wl-clipboard
      ripgrep

      # media
      #inkscape
      gimp
      #darktable

      # Office
      #kicad
      #octaveFull
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

      #fractal
      alpaca
      resources
    ])
    ++ (lib.lists.optionals isNiri [
      libreoffice
      wireplumber
      brightnessctl
      nautilus
      gnome-clocks
      mpv
      #fractal
      alpaca
      fragments
      bzmenu
      #iwmenu
      playerctl
    ])
