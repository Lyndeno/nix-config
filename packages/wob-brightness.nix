{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      brightnessctl
      gnused
    ];

    text = ''
      # Pull the "(NN%)" percentage out of brightnessctl's output.
      percent() {
        sed -En 's/.*\(([0-9]+)%\).*/\1/p'
      }

      # Push a value onto the wob overlay socket (0-100 bar).
      wob() {
        printf '%s\n' "$1" >"$XDG_RUNTIME_DIR/wob.sock"
      }

      case "''${1:-}" in
        up)
          wob "$(brightnessctl set +5% | percent)"
          ;;
        down)
          # -n keeps a floor so the backlight never drops fully dark.
          wob "$(brightnessctl -n set 5%- | percent)"
          ;;
        *)
          echo "usage: ${pname} {up|down}" >&2
          exit 1
          ;;
      esac
    '';

    meta.platforms = lib.platforms.linux;
  }
