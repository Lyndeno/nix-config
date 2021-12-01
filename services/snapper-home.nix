{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.snapper-home;
in
{
  options = {
      services = {
          snapper-home = {
              enable = mkOption {type = types.bool; default = false; };
          };
      };
  };

  config = mkIf cfg.enable {
    services.snapper = {
      configs = {
        home = {
          subvolume = "/home";
          extraConfig = ''
            ALLOW_USERS="lsanche"
            TIMELINE_CREATE=yes
            TIMELINE_CLEANUP=yes
          '';
          };
      };
    };
  };
}
