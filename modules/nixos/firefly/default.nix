{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age.secrets.firefly-id = {
    file = ../../../secrets/${config.networking.hostName}/firefly_id.age;
    owner = config.services.firefly-iii.user;
    inherit (config.services.firefly-iii) group;
  };

  services = {
    firefly-iii = let
      ff-user = config.services.firefly-iii.user;
    in {
      enable = true;
      virtualHost = "firefly.${config.networking.domain}";
      enableNginx = true;
      settings = {
        DB_USERNAME = ff-user;
        DB_CONNECTION = "pgsql";
        DB_DATABASE = ff-user;
        APP_KEY_FILE = config.age.secrets.firefly-id.path;
      };
    };

    postgresql = let
      ff-user = config.services.firefly-iii.user;
    in {
      ensureDatabases = [ff-user];
      ensureUsers = [
        {
          name = ff-user;
          ensureDBOwnership = true;
        }
      ];
    };

    # port = null: firefly-iii manages its own nginx virtualHost via enableNginx;
    # this entry just layers TLS/ACME on top via localProxy.
    localProxy.subDomains.firefly = {
      port = null;
    };
  };
}
