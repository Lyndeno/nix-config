{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      lm_sensors
      jq
    ];

    bashOptions = [];

    text = ''
      sensors -j | jq --unbuffered -c '
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
  }
