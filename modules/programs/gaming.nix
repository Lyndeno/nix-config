{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.programs.gaming;
in
{
  options = {
      modules = {
        programs = {
          gaming = {
              enable = mkOption {type = types.bool; default = false; };
              steam = {
                enable = mkOption {type = types.bool; default = true; };
              };
              minecraft = {
                enable = mkOption {type = types.bool; default = true; };
              };
              emulation = {
                enable = mkOption {type = types.bool; default = true; };
                wii = {
                  enable = mkOption {type = types.bool; default = true; };
                };
                gamecube = {
                  enable = mkOption {type = types.bool; default = true; };
                };
              };
          };
        };
      };
  };

  config = mkIf cfg.enable {
    programs.steam.enable = cfg.steam.enable;

    environment.systemPackages = with cfg; (mkMerge [
      (mkIf minecraft.enable [ pkgs.minecraft ])
      (with emulation; mkIf enable ( mkMerge [
        (mkIf wii.enable [ pkgs.dolphin-emu-beta ])
        (mkIf gamecube.enable [ pkgs.dolphin-emu-beta ])
        ]))
    ]);
  };
}
