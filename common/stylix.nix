{inputs}: let
  base16Scheme = "${inputs.base16-schemes}/gruvbox-dark-hard.yaml";
in {
  enable = true;
  image = "${inputs.wallpapers}/sedona.jpg";
  inherit base16Scheme;
  targets = {
    grub.enable = false;
    plymouth.enable = false;
    console.enable = false;
    nixos-icons.enable = false;
  };
}
