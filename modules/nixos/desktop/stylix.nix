{
  inputs,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  stylix = {
    polarity = "dark";
    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };
    opacity = {
      terminal = 0.85;
      popups = 0.85;
      desktop = 0.85;
    };
    fonts = let
      cascadia = pkgs.nerd-fonts.caskaydia-cove;
    in {
      serif = {
        package = inputs.apple-fonts.packages.${system}.sf-pro-nerd;
        name = "SFProDisplay Nerd Font";
      };
      sansSerif = {
        package = inputs.apple-fonts.packages.${system}.sf-pro-nerd;
        name = "SFProDisplay Nerd Font";
      };
      monospace = {
        package = cascadia;
        name = "CaskaydiaCove Nerd Font Mono";
      };
      sizes = {
        desktop = 11;
        popups = 12;
      };
    };
  };
}
