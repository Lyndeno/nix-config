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
      grim
      img-blur
      img-darken
      swaylock
    ];

    text = ''
      trap "swaylock -fF" ERR INT

      scratch=$(mktemp -d -t lockscreenshot.XXX)
      trap 'rm -rf "''${scratch}"' EXIT

      args=(-fF)

      for monitor in $(niri msg --json outputs | jq -r 'to_entries[] | select(.value.current_mode != null) | .key')
      do
          img="''${scratch}/''${monitor}.png"
          {
              grim -o "''${monitor}" "''${img}" &&
              img-blur "''${img}" "''${img}" > /dev/null
              img-darken "''${img}" "''${img}" > /dev/null
          } &
          args+=(--image="''${monitor}:''${img}")
      done

      wait

      exec swaylock "''${args[@]}"
    '';

    meta.platforms = lib.platforms.linux;
  }
