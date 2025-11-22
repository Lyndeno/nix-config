{inputs}: let
  base16Scheme = "${inputs.base16-schemes}/base16/gruvbox-dark-hard.yaml";
in {
  enable = true;
  image = "${inputs.wallpapers}/sedona.jpg";
  overlays.enable = false;
  inherit base16Scheme;
  targets = {
    plymouth.enable = false;
    nixos-icons.enable = false;
    console.enable = false;
  };
}
