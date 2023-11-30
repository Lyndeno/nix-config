{pkgs}: {
  enable = true;
  ensureDatabases = ["paperless"];
  package = pkgs.postgresql_16;
  ensureUsers = [
    {
      name = "paperless";
      ensureDBOwnership = true;
    }
  ];
}
