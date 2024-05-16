{config}: {
  enable = true;
  settings = {
    server.listen = ["0.0.0.0:4918" "[::]:4918"];
    accounts = {
      auth-type = "htpasswd.default";
      acct-type = "unix";
    };
    htpasswd.default = {
      htpasswd = config.age.secrets.webdav.path;
    };
    location = [
      {
        route = ["/public/*path"];
        directory = "/data/bigpool/seedvault";
        handler = "filesystem";
        methods = ["webdav-rw"];
        autoIndex = true;
        auth = "true";
        setuid = true;
      }
    ];
  };
}
