{pkgs, lib, inputs, ...}:
let
  base16Scheme = "${inputs.base16-schemes}/atelier-dune.yaml";
  sf-pro = pkgs.stdenv.mkDerivation rec {
    name = "sf-pro";
    version = "0.0.1";

    src = pkgs.fetchurl {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      sha256 = "sha256-g/eQoYqTzZwrXvQYnGzDFBEpKAPC8wHlUw3NlrBabHw=";
    };

    buildInputs = [ pkgs.undmg pkgs.p7zip ];
    buildPhases = [ "unpackPhase" "installPhase" ];
    setSourceRoot = "sourceRoot=`pwd`";

    installPhase = ''
      7z x 'SF Pro Fonts.pkg'
      7z x 'Payload~'
      mkdir -p $out/share/fonts
      mkdir -p $out/share/fonts/opentype
      mkdir -p $out/share/fonts/truetype
      mv Library/Fonts/*.otf $out/share/fonts/opentype
      mv Library/Fonts/*.ttf $out/share/fonts/truetype
    '';
  };
in {
    fonts.fonts = [ sf-pro ];
    stylix = {
      image = "${inputs.wallpapers}/starry.jpg";
      base16Scheme = base16Scheme;
      targets.swaylock.useImage = false;
      targets.grub.enable = false;
      fonts = let
        cascadia = (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" ]; });
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
