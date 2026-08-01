{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;

  package = pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      wireplumber
      gnugrep
      gnused
    ];

    text = ''
      sink="@DEFAULT_AUDIO_SINK@"
      source="@DEFAULT_AUDIO_SOURCE@"

      # wpctl is overridable so the parser can be tested with a stub.
      wpctl="''${WPCTL:-wpctl}"

      # Push a value onto the wob overlay socket (0-100 bar).
      wob() {
        printf '%s\n' "$1" >"$XDG_RUNTIME_DIR/wob.sock"
      }

      level() {
        "$wpctl" get-volume "$sink" | sed 's/[^0-9]//g'
      }

      muted() {
        "$wpctl" get-volume "$sink" | grep -q MUTED
      }

      case "''${1:-}" in
        up)
          # When muted, show 0 without changing the level.
          if muted; then wob 0; else "$wpctl" set-volume "$sink" 2%+ && wob "$(level)"; fi
          ;;
        down)
          if muted; then wob 0; else "$wpctl" set-volume "$sink" 2%- && wob "$(level)"; fi
          ;;
        mute)
          "$wpctl" set-mute "$sink" toggle
          if muted; then wob 0; else wob "$(level)"; fi
          ;;
        mic-mute)
          "$wpctl" set-mute "$source" toggle
          ;;
        *)
          echo "usage: ${pname} {up|down|mute|mic-mute}" >&2
          exit 1
          ;;
      esac
    '';

    meta.description = "Adjusts volume/mute with a wob overlay bar";
    meta.platforms = lib.platforms.linux;

    passthru.tests = let
      # Stub wpctl: report a fixed get-volume line, ignore set-* commands.
      stub = getVolume:
        pkgs.writeShellScript "wpctl-stub" ''
          case "$1" in
            get-volume) echo "${getVolume}" ;;
            *) ;;
          esac
        '';
      run = name: getVolume: arg: expected:
        pkgs.runCommandLocal "${pname}-${name}" {} ''
          export XDG_RUNTIME_DIR="$PWD"
          export WPCTL=${stub getVolume}
          ${lib.getExe package} ${arg}
          got=$(cat "$XDG_RUNTIME_DIR/wob.sock")
          [ "$got" = "${expected}" ] || {
            echo "expected '${expected}', got '$got'" >&2
            exit 1
          }
          touch "$out"
        '';
    in {
      # Unmuted: raising reports the parsed numeric level.
      level = run "level" "Volume: 0.50" "up" "050";
      # Muted: raising reports 0 without touching the level.
      muted = run "muted" "Volume: 0.50 [MUTED]" "up" "0";
    };
  };
in
  package
