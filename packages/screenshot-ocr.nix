{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      grim
      slurp
      tesseract
      wl-clipboard
    ];

    text = ''
      TMPFILE=$(mktemp --suffix=.png)
      trap 'rm -f "$TMPFILE"' EXIT
      grim -g "$(slurp -b '#00000088')" "$TMPFILE"
      tesseract "$TMPFILE" stdout | wl-copy
    '';

    meta.platforms = lib.platforms.linux;
  }
