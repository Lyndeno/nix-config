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

    # Print the hostname of the active Tailscale exit node (empty if none).
    text = ''
      tailscale status --peers --json \
        | jq '.ExitNodeStatus.ID as $node_id | .Peer[] | select(.ID==$node_id) | .HostName' \
        | tr -d '"'
    '';

    meta.platforms = lib.platforms.linux;
  }
