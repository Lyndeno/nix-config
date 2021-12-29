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
              enable = mkEnableOption "Gaming software and games";
              steam = {
                enable = mkEnableOption "Steam";
              };
              minecraft = {
                enable = mkEnableOption "Minecraft";
              };
              emulation = {
                enable = mkEnableOption "Emulation software";
                wii = {
                  enable = mkEnableOption "Wii emulation (Dolphin)";
                };
                gamecube = {
                  enable = mkEnableOption "Gamecube emulation (Dolphin)";
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
