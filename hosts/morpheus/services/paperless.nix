{
  pkgs,
  lib,
}: {
  enable = true;
  address = "0.0.0.0";
  settings = {
    PAPERLESS_DBHOST = "/run/postgresql";
    LD_LIBRARY_PATH = "${lib.getLib pkgs.mkl}/lib";
  };
}
