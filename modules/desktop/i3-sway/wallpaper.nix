{ config, pkgs, ...}: {width, height}:
pkgs.stdenv.mkDerivation ( with config.scheme; {
  name = "gen-wallpaper.png";
  src = pkgs.writeTextFile {
    name = "template.svg";
    text = builtins.readFile (config.scheme { template = builtins.readFile ./wallpaper.svg; });
  };
  buildInputs = with pkgs; [ inkscape ];
  unpackPhase = "true";
  buildPhase = ''
    inkscape --export-type="png" $src -w ${toString width} -h ${toString height} -o wallpaper.png
    '';
  installPhase = "install -Dm0644 wallpaper.png $out";
})
