{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;

  package = pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      lm_sensors
      jq
    ];

    bashOptions = [];

    text = ''
      # sensors is overridable so the jq filter can be tested with a stub.
      sensors="''${SENSORS:-sensors}"

      "$sensors" -j | jq --unbuffered -c '
        [to_entries[]
          | {controller: .key} as $entry
          | .value | to_entries[]
          | select(.key | test("(?i)fan")) as $sensor_type
          | .value | to_entries[]
          | select(.key | test("_input$"))
          | {
              controller: $entry.controller,
              sensor: $sensor_type.key,
              name: (.key | gsub("_input$"; "")),
              value: .value
            }
        ]
        | ([.[].value] | map(select(. > 0))) as $nonzero
        | if ($nonzero | length) > 0
          then {
            text: "󰈐 \(($nonzero | add / length) | floor)",
            tooltip: ([.[] | "\(.controller) \(.sensor) \(.name): \(.value | floor) RPM"] | join("\n"))
          }
          else empty
          end
      '
    '';

    meta.platforms = lib.platforms.linux;

    passthru.tests = {
      # Two fans at 1000 and 2000 RPM should report the floored average (1500).
      average = pkgs.runCommandLocal "${pname}-average" {} ''
        export SENSORS=${pkgs.writeShellScript "sensors-stub" ''
          echo '{"nct6798-isa-0290":{"fan1":{"fan1_input":1000.0},"fan2":{"fan2_input":2000.0}}}'
        ''}
        got=$(${lib.getExe package})
        echo "$got" | grep -q 'fan1: 1000 RPM' || { echo "bad tooltip: $got" >&2; exit 1; }
        echo "$got" | grep -q '1500' || { echo "wrong average: $got" >&2; exit 1; }
        touch "$out"
      '';
    };
  };
in
  package
