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
      satty
    ];

    text = ''
      grim -t ppm -g "$(slurp -d -b '#00000088')" - | satty --filename - \
        --initial-tool arrow \
        --copy-command wl-copy \
        --actions-on-escape save-to-clipboard,exit \
        --brush-smooth-history-size 5
    '';

    meta.description = "Region screenshot with annotation (grim/slurp + satty)";
    meta.platforms = lib.platforms.linux;
  }
