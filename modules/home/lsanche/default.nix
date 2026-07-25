{pkgs, ...}: {
  programs.git = {
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE90+2nMvJzOmkEGT3cyqHMESrrPQwVhe9/ToSlteJbB";
      signByDefault = true;
      format = "ssh";
    };
    settings = {
      user = {
        name = "Lyndon Sanche";
        email = "lsanche@lyndeno.ca";
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Create sshconfig with aliases for all the hosts in this config.
    # We assume each host is accessable via hostname, in this case by Tailscale.
    # We specify the host key so our ssh agent does not have to keep looking and possibly
    # hitting the limit before finding the right key.
    matchBlocks = let
      keys = (import ../../../pubKeys.nix).lsanche;
      gitKeys = import ./gitKeys.nix;
      mkPubkeyFile = name: key: pkgs.writeText "${name}.pub" "${key}\n";
      mkGitForge = {
        hostname,
        keyName,
        key,
      }: {
        inherit hostname;
        port = 443;
        user = "git";
        identitiesOnly = true;
        identityFile = "${mkPubkeyFile keyName key}";
      };
    in
      (builtins.mapAttrs (name: value: {
          hostname = name;
          identityFile = "${mkPubkeyFile "lsanche-${name}" value}";
          identitiesOnly = true;
          forwardAgent = true;
        })
        keys)
      // {
        "github.com" = mkGitForge {
          hostname = "ssh.github.com";
          keyName = "github";
          key = gitKeys.github;
        };
        "gitlab.com" = mkGitForge {
          hostname = "altssh.gitlab.com";
          keyName = "gitlab";
          key = gitKeys.gitlab;
        };
        "gitlabalt" = mkGitForge {
          hostname = "altssh.gitlab.com";
          keyName = "gitlabalt";
          key = gitKeys.gitlabalt;
        };
      };
  };
}
