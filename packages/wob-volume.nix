{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      wireplumber
      gnugrep
      gnused
    ];

    text = ''
      sink="@DEFAULT_AUDIO_SINK@"
      source="@DEFAULT_AUDIO_SOURCE@"

      # Push a value onto the wob overlay socket (0-100 bar).
      wob() {
        printf '%s\n' "$1" >"$XDG_RUNTIME_DIR/wob.sock"
      }

      level() {
        wpctl get-volume "$sink" | sed 's/[^0-9]//g'
      }

      muted() {
        wpctl get-volume "$sink" | grep -q MUTED
      }

      case "''${1:-}" in
        up)
          # When muted, show 0 without changing the level.
          if muted; then wob 0; else wpctl set-volume "$sink" 2%+ && wob "$(level)"; fi
          ;;
        down)
          if muted; then wob 0; else wpctl set-volume "$sink" 2%- && wob "$(level)"; fi
          ;;
        mute)
          wpctl set-mute "$sink" toggle
          if muted; then wob 0; else wob "$(level)"; fi
          ;;
        mic-mute)
          wpctl set-mute "$source" toggle
          ;;
        *)
          echo "usage: ${pname} {up|down|mute|mic-mute}" >&2
          exit 1
          ;;
      esac
    '';

    meta.platforms = lib.platforms.linux;
  }
