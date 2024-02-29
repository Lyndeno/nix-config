{
  config,
  inputs,
}: let
  # deadnix: skip
  cfg = {pkgs, ...} @ args:
    inputs.haumea.lib.load {
      src = ../../../home/lsanche;
      inputs =
        args
        // {
          isDesktop = config.mods.desktop.enable;
          isPlasma = config.mods.plasma.enable;
          isGnome = config.mods.gnome.enable;
          inherit inputs;
        };
      transformer = [
        inputs.haumea.lib.transformers.liftDefault
      ];
    };
in
  {osConfig, ...}: {
    imports = [cfg];

    home.stateVersion = osConfig.system.stateVersion;
  }
