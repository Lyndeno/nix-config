# meta.description = "Base user config: Git and SSH keys"
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
    settings = let
      keys = (import ../../../pubKeys.nix).lsanche;
      gitKeys = import ./gitKeys.nix;
      mkPubkeyFile = name: key: pkgs.writeText "${name}.pub" "${key}\n";
      mkGitForge = {
        hostname,
        keyName,
        key,
      }: {
        HostName = hostname;
        Port = 443;
        User = "git";
        IdentitiesOnly = true;
        IdentityFile = "${mkPubkeyFile keyName key}";
      };
    in
      (builtins.mapAttrs (name: value: {
          HostName = name;
          IdentityFile = "${mkPubkeyFile "lsanche-${name}" value}";
          IdentitiesOnly = true;
          ForwardAgent = true;
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
