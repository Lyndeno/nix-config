{
  pkgs,
  pname,
}:
pkgs.writeShellApplication {
  name = pname;

  runtimeInputs = [pkgs.imagemagick];

  text = ''
    magick "$1" -blur 0x50 "$2"
  '';
}
