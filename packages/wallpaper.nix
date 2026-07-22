{
  inputs,
  pkgs,
  ...
}:
pkgs.runCommand "wallpaper" {} ''
  ln -s ${inputs.wallpapers}/sedona.jpg $out
''
