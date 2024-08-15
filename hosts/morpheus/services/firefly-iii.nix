{config}: let
  ff-user = config.services.firefly-iii.user;
in {
  enable = true;
  virtualHost = "morpheus";
  enableNginx = true;
  settings = {
    DB_USERNAME = ff-user;
    DB_CONNECTION = "pgsql";
    DB_DATABASE = ff-user;
    APP_KEY_FILE = config.age.secrets.firefly-id.path;
  };
}
