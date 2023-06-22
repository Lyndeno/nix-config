{
  config,
  pkgs,
  lib,
  inputs,
  lsLib,
}:
import ../../../home/lsanche/home.nix {
  config = config.home-manager.users.lsanche;
  isDesktop = config.mods.desktop.enable;
  inherit pkgs lib inputs lsLib;
  inherit (config.system) stateVersion;
}
