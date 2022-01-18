{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.programs.gaming;
  mkTrueEnableOption = name: mkEnableOption "${name}" // { default = true; };
in
{
  options = {
      modules = {
        programs = {
          gaming = {
              enable = mkEnableOption "Gaming software and games";
              steam = {
                enable = mkTrueEnableOption "Steam";
              };
              minecraft = {
                enable = mkTrueEnableOption "Minecraft";
              };
              emulation = {
                enable = mkTrueEnableOption "Emulation software";
                wii = {
                  enable = mkTrueEnableOption "Wii emulation (Dolphin)";
                };
                gamecube = {
                  enable = mkTrueEnableOption "Gamecube emulation (Dolphin)";
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
