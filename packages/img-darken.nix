{
  pkgs,
  pname,
}:
pkgs.writeShellApplication {
  name = pname;

  runtimeInputs = [pkgs.imagemagick];

  text = ''
    magick "$1" -modulate 40 "$2"
  '';
}
