{
  pkgs,
  config,
}: let
  ff-user = config.services.firefly-iii.user;
  atticd-user = config.services.atticd.user;
in {
  enable = true;
  ensureDatabases = [ff-user atticd-user];
  package = pkgs.postgresql_16;
  ensureUsers = [
    {
      name = ff-user;
      ensureDBOwnership = true;
    }
    {
      name = atticd-user;
      ensureDBOwnership = true;
    }
  ];
}
