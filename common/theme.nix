{
  pkgs,
  inputs,
  ...
}: let
  base16Scheme = "${inputs.base16-schemes}/atelier-dune.yaml";
in {
  stylix = {
    image = "${inputs.wallpapers}/starry.jpg";
    inherit base16Scheme;
    targets.grub.enable = false;
    targets.chromium.enable = false;
    fonts = let
      cascadia = pkgs.nerdfonts.override {fonts = ["CascadiaCode"];};
    in {
      serif = {
        package = cascadia;
        name = "CaskaydiaCove Nerd Font";
      };
      sansSerif = {
        package = cascadia;
        name = "CaskaydiaCove Nerd Font";
      };
      monospace = {
        package = cascadia;
        name = "CaskaydiaCove Nerd Font Mono";
      };
    };
  };
}
