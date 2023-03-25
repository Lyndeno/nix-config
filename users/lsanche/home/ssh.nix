{pkgs, ...}: {
  programs.ssh = {
    enable = true;

    # Create sshconfig with aliases for all the hosts in this config.
    # We assume each host is accessable via hostname, in this case by Tailscale.
    # We specify the host key so our ssh agent does not have to keep looking and possibly
    # hitting the limit before finding the right key.
    matchBlocks = let
      keys = (import ../info.nix).hostAuthorizedKeys;
    in
      (builtins.mapAttrs (name: value: {
          hostname = name;
          identityFile = "${(pkgs.writeText "lsanche-${name}.pub" ''
            ${value}
          '')}";
          identitiesOnly = true;
        })
        keys)
      // {
        "* !*.repo.borgbase.com" = {
          extraOptions = {
            "IdentityAgent" = "~/.1password/agent.sock"; # 1password **should** exist if desktop is enabled
          };
        };
      };
  };
}