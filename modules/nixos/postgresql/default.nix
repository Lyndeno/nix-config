# meta.description = "PostgreSQL database server"
{pkgs, ...}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
  };
}
