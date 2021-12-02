{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.services.torrents;
in
{
  options = {
      modules = {
        services = {
          torrents = {
              enable = mkOption {type = types.bool; default = false; };
          };
        };
      };
  };

  config = mkIf cfg.enable {
    services.transmission = {
        enable = true;
        openFirewall = true;
        group = "media";
        settings = {
            download-dir = "/srv/torrents";
            incomplete-dir = "/srv/torrents/.incomplete";
            incomplete-dir-enabled = true;
            rpc-port = 9091;
        };
    };
  };
}
