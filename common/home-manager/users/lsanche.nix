{
  config,
  inputs,
}:
import ../../../home/lsanche/home.nix {
  isDesktop = config.mods.desktop.enable;
  inherit inputs;
  inherit (config.system) stateVersion;
}
