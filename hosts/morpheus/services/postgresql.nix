{
  pkgs,
  config,
}: let
  ff-user = config.services.firefly-iii.user;
in {
  enable = true;
  ensureDatabases = ["paperless" ff-user];
  package = pkgs.postgresql_16;
  ensureUsers = [
    {
      name = "paperless";
      ensureDBOwnership = true;
    }
    {
      name = ff-user;
      ensureDBOwnership = true;
    }
  ];
}
