{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age.secrets.attic-token.file = ../../../secrets/morpheus/attic_token.age;

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
          path = "/data/bigpool/services/attic";
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
