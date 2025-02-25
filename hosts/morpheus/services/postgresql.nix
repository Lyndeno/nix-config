{
  pkgs,
  config,
}: let
  ff-user = config.services.firefly-iii.user;
in {
  enable = true;
  ensureDatabases = [ff-user];
  package = pkgs.postgresql_16;
  ensureUsers = [
    {
      name = ff-user;
      ensureDBOwnership = true;
    }
  ];
}
