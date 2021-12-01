{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.gaming;
in
{
  options = {
      modules = {
          gaming = {
              enable = mkOption {type = types.bool; default = false; };
              steam = {
                enable = mkOption {type = types.bool; default = true; };
              };
              minecraft = {
                enable = mkOption {type = types.bool; default = true; };
              };
          };
      };
  };

  config = mkIf cfg.enable {
    programs.steam.enable = cfg.steam.enable;

    environment.systemPackages = mkIf cfg.minecraft.enable [
      pkgs.minecraft
    ];
  };
}
