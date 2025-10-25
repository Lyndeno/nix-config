{
  pkgs,
  config,
}: {
  enable = true;
  package = pkgs.garage_2;
  environmentFile = config.age.secrets.garage.path;
  extraEnvironment = {
    GARAGE_LOG_TO_JOURNALD = "true";
  };
  settings = {
    data_dir = "/data/bigpool/services/garage";
    db_engine = "sqlite";

    replication_factor = 1;

    rpc_bind_addr = "[::]:3901";
    rpc_public_addr = "127.0.0.1:3901";

    s3_api = {
      s3_region = "garage";
      api_bind_addr = "[::]:3900";
      root_domain = ".s3.garage.morpheus";
    };

    admin = {
      api_bind_addr = "[::]:3903";
    };
  };
}
