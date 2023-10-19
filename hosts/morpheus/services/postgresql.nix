{pkgs}: {
  enable = true;
  ensureDatabases = ["paperless"];
  package = pkgs.postgresql_16;
  initialScript = pkgs.writeText "init-sql-script" ''
    ALTER DATABASE paperless OWNER TO paperless;
  '';
  ensureUsers = [
    {
      name = "paperless";
      ensurePermissions = {
        "DATABASE paperless" = "ALL PRIVILEGES";
      };
    }
  ];
}
