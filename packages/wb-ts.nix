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
      tailscale status --peers --json | jq -c -f ${./wb-ts.jq}
    '';

    meta.description = "Waybar module showing the active Tailscale exit node";
    meta.platforms = lib.platforms.linux;
  }
