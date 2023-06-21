{
  config,
  pkgs,
  lib,
  inputs,
  lsLib,
}:
lib.mkIf config.mods.desktop.enable (import ../../../home/lsanche/home.nix {
  config = config.home-manager.users.lsanche;
  inherit pkgs lib inputs lsLib;
  inherit (config.system) stateVersion;
})
