{
  pkgs,
  pname,
}:
pkgs.writeShellApplication {
  name = pname;

  runtimeInputs = with pkgs; [coreutils vips];

  text = ''
    name=$(basename "$1")
    ext="''${name##*.}"
    [[ "$ext" == "$name" ]] && ext="jpg"
    tmp=$(mktemp --suffix=".$ext")
    trap 'rm -f "$tmp"' EXIT
    vips linear "$1" "$tmp" 0.4 0 2>/dev/null
    mv "$tmp" "$2"
  '';

  meta.description = "Writes a darkened copy of an image (wallpaper helper)";
}
