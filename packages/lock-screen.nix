{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      coreutils
      niri
      jq
      grim
      img-blur
      img-darken
      swaylock
    ];

    text = ''
      # Fall back to a plain lock if screenshot/blur setup fails, but log it
      # first so the failure is visible in the journal instead of silent.
      trap 'echo "lock-screen: screenshot setup failed, falling back to plain lock" >&2; swaylock -fF' ERR INT

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
