{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      niri
      jq
    ];

    bashOptions = [];

    text = ''
      niri msg --json event-stream | jq --unbuffered -rc -f ${./wb-cast.jq}
    '';

    meta.description = "Waybar module showing the current niri screencast target";
    meta.platforms = lib.platforms.linux;
  }
