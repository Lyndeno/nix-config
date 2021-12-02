{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.services.snapper-home;
in
{
  options = {
    modules = {
      services = {
          snapper-home = {
              enable = mkOption {type = types.bool; default = false; };
          };
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
