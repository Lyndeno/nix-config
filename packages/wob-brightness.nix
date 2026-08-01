{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;

  package = pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      brightnessctl
      gnused
    ];

    text = ''
      # brightnessctl is overridable so the parser can be tested with a stub.
      brightnessctl="''${BRIGHTNESSCTL:-brightnessctl}"

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
          wob "$("$brightnessctl" set +5% | percent)"
          ;;
        down)
          # -n keeps a floor so the backlight never drops fully dark.
          wob "$("$brightnessctl" -n set 5%- | percent)"
          ;;
        *)
          echo "usage: ${pname} {up|down}" >&2
          exit 1
          ;;
      esac
    '';

    meta.description = "Adjusts screen brightness with a wob overlay bar";
    meta.platforms = lib.platforms.linux;

    passthru.tests = {
      # Feed a canned brightnessctl line and assert the percentage lands on wob.
      percent = pkgs.runCommandLocal "${pname}-percent" {} ''
        export XDG_RUNTIME_DIR="$PWD"
        export BRIGHTNESSCTL=${pkgs.writeShellScript "brightnessctl-stub" ''
          echo "Current brightness: 96 (37%)"
        ''}

        for dir in up down; do
          ${lib.getExe package} "$dir"
          got=$(cat "$XDG_RUNTIME_DIR/wob.sock")
          [ "$got" = "37" ] || {
            echo "$dir: expected 37, got '$got'" >&2
            exit 1
          }
        done
        touch "$out"
      '';
    };
  };
in
  package
