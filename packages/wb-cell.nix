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
      iwd
      gnused
    ];

    # Show the phone's cellular signal/network type (via BatteryInfoServer,
    # https://github.com/mfaizanse/BatteryInfoServer, over its Tailscale
    # MagicDNS name) next to the network module, but only while this machine
    # is on the "Cypher" Wi-Fi network the phone also sits on. Pass
    # --skip-ssid-check to query regardless of SSID, for testing.
    text = ''
      skip_ssid_check=false
      for arg in "$@"; do
        case "$arg" in
          --skip-ssid-check) skip_ssid_check=true ;;
        esac
      done

      ssid=$(iwctl station wlan0 show 2>/dev/null \
        | grep "Connected network" \
        | sed -E 's/^[[:space:]]*Connected network[[:space:]]+//; s/[[:space:]]+$//' \
        || true)

      if [ "$skip_ssid_check" != true ] && [ "$ssid" != "Cypher" ]; then
        echo '{"text":""}'
        exit 0
      fi

      response=$(curl -sS -m 5 --fail "http://cypher:9091/battery" 2>/dev/null || true)

      if [ -z "$response" ]; then
        echo '{"text":""}'
      else
        echo "$response" | jq -c '
          .environment as $e
          | ([$e.cellular_signal_level // 0, 0] | max) as $raw
          | ([$raw, 4] | min) as $level
          | (["󰣾","󰣴","󰣶","󰣸","󰣺"][$level]) as $icon
          | ($e.cellular_network_type // "unknown") as $type
          | {
              text: ($type + " " + $icon),
              tooltip: ("Cellular: " + $type + "\nSignal: " + ($level | tostring) + "/4")
            }
        '
      fi
    '';

    meta.description = "Waybar module showing phone cellular signal/type via BatteryInfoServer";
    meta.platforms = lib.platforms.linux;
  }
