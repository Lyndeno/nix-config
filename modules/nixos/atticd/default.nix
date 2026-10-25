# meta.description = "Attic binary cache server (atticd)"
{config, ...}: let
  storagePath = "/var/lib/attic-storage";
in {
  age.secrets.attic-token.file = ../../../secrets/${config.networking.hostName}/attic_token.age;

  # ReadWritePaths doesn't pull in a mount dependency; without this atticd could
  # start against the empty mountpoint and write chunks to the root filesystem.
  systemd.services.atticd.unitConfig.RequiresMountsFor = [storagePath];

  services = {
    atticd = {
      enable = true;
      environmentFile = config.age.secrets.attic-token.path;
      settings = {
        database = {
          url = "postgresql:///atticd?host=/run/postgresql";
        };
        storage = {
          type = "local";
          path = storagePath;
        };
        # ZFS handles compression for us
        compression.type = "none";
      };
    };

    postgresql = let
      atticd-user = config.services.atticd.user;
    in {
      ensureDatabases = [atticd-user];
      ensureUsers = [
        {
          name = atticd-user;
          ensureDBOwnership = true;
        }
      ];
    };

    localProxy.subDomains.cache = {
      port = 8080;
    };
  };
}
