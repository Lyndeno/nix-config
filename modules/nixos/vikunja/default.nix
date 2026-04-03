{config, ...}: {
  services = {
    vikunja = {
      enable = true;
      database = {
        type = "postgres";
        host = "/run/postgresql";
      };
      frontendScheme = "http";
      frontendHostname = "morpheus";
    };

    postgresql = let
      vikunja-user = config.services.vikunja.database.user;
      vikunja-db = config.services.vikunja.database.database;
    in {
      ensureDatabases = [vikunja-user];
      ensureUsers = [
        {
          name = vikunja-db;
          ensureDBOwnership = true;
        }
      ];
    };

    localProxy.subDomains.tasks = {
      inherit (config.services.vikunja) port;
    };
  };
}
