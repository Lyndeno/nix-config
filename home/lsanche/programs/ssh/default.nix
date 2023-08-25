{
  pkgs,
  super,
}: {
  enable = true;

  # Create sshconfig with aliases for all the hosts in this config.
  # We assume each host is accessable via hostname, in this case by Tailscale.
  # We specify the host key so our ssh agent does not have to keep looking and possibly
  # hitting the limit before finding the right key.
  matchBlocks = let
    keys = super.pubKeys;
    inherit (super) gitKeys;
  in
    (builtins.mapAttrs (name: value: {
        hostname = name;
        identityFile = "${(pkgs.writeText "lsanche-${name}.pub" ''
          ${value}
        '')}";
        identitiesOnly = true;
        forwardAgent = true;
      })
      keys)
    // {
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identitiesOnly = true;
        identityFile = "${(pkgs.writeText "github.pub" ''
          ${gitKeys.github}
        '')}";
      };

      "gitlab.com" = {
        hostname = "altssh.gitlab.com";
        port = 443;
        user = "git";
        identitiesOnly = true;
        identityFile = "${(pkgs.writeText "gitlab.pub" ''
          ${gitKeys.gitlab}
        '')}";
      };
    };
}
