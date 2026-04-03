{pkgs, ...}: {
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
    };
    postgresqlBackup.enable = true;
  };
}
