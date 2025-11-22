{config}: {
  #enable = true;
  environmentFile = config.age.secrets.attic-token.path;
  settings = {
    database = {
      url = "postgresql:///atticd?host=/run/postgresql";
    };
    storage = {
      type = "s3";
      region = "garage";
      bucket = "attic";
      endpoint = "http://morpheus:3900";
    };
  };
}
