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
      tailscale
      jq
    ];

    # Print the active Tailscale exit node's hostname as waybar text, with a
    # tooltip listing every available exit node's hostname, IP, and selection.
    text = ''
      tailscale status --peers --json | jq -c '
        [.Peer[] | select(.ExitNodeOption == true)] as $exit_nodes
        | (($exit_nodes[] | select(.ExitNode) | .HostName) // "") as $active
        | ($exit_nodes | map(.HostName | length) | max // 0) as $width
        | {
            text: $active,
            tooltip: (
              if ($exit_nodes | length) == 0
              then "No exit nodes available"
              else $exit_nodes
                | map(
                    (.HostName + (" " * ($width - (.HostName | length))) + " (" + (.TailscaleIPs[0] // "?") + ")") as $line
                    | if .ExitNode then "<b><i>" + $line + "</i></b>" else $line end
                  )
                | join("\n")
              end
            )
          }
      '
    '';

    meta.description = "Waybar module showing the active Tailscale exit node";
    meta.platforms = lib.platforms.linux;
  }
