{config}: {
  enable = true;
  environmentFile = config.age.secrets.attic-token.path;
  settings = {
    database = {
      url = "postgresql:///atticd?host=/run/postgresql";
    };
    storage = {
      type = "s3";
      region = "us-east-1";
      bucket = "attic";
      endpoint = "http://localhost:9000";
    };
  };
}
