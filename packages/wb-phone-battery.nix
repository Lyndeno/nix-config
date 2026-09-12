{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      curl
      jq
    ];

    # Poll the BatteryInfoServer app (https://github.com/mfaizanse/BatteryInfoServer)
    # running on the phone's Tailscale MagicDNS name. Prints an empty text field
    # (hidden via hide-empty-text) when the phone is unreachable.
    text = ''
      response=$(curl -sS -m 5 --fail "http://cypher:9091/battery" 2>/dev/null || true)

      if [ -z "$response" ]; then
        echo '{"text":""}'
      else
        echo "$response" | jq -c '
          .status as $s | .device as $d | .environment as $e
          | ([$s.level / 10 | floor, 10] | min) as $idx
          | ["󰠒","󰠈","󰠉","󰠊","󰠋","󰠌","󰠍","󰠎","󰠏","󰠐","󰠇"][$idx] as $level_icon
          | (if $s.is_charging then "󰠇" elif $s.level <= 15 then "󰠑" else $level_icon end) as $icon
          | {
              text: (
                $icon
                + (if $s.is_charging or $s.level < 50
                   then " " + ($s.level | tostring) + "%"
                   else "" end)
              ),
              tooltip: (
                $d.model
                + "\nBattery: " + ($s.level | tostring) + "% (" + $s.health + ")"
                + "\nTemp: " + $s.temp
                + "\nPower: " + $s.power_source
                + "\nNetwork: " + $e.data_connection
              ),
              class: [
                (if $s.level <= 15 then "critical" elif $s.level <= 30 then "warning" else empty end),
                (if $s.is_charging then "charging" else empty end)
              ]
            }
        '
      fi
    '';

    meta.description = "Waybar module showing phone battery status via BatteryInfoServer";
    meta.platforms = lib.platforms.linux;
  }
