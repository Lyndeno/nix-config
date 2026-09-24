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
        echo "$response" | jq -c -f ${./wb-phone-battery.jq}
      fi
    '';

    meta.description = "Waybar module showing phone battery status via BatteryInfoServer";
    meta.platforms = lib.platforms.linux;
  }
