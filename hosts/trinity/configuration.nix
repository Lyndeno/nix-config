{
  inputs,
  pkgs,
  lib,
  flake,
  config,
  ...
}: let
  hostConfig = inputs.haumea.lib.load {
    src = ./config;
    inputs = {inherit inputs pkgs lib flake config;};
    transformer = inputs.haumea.lib.transformers.liftDefault;
  };
in {
  imports = [
    hostConfig
    flake.modules.nixos.common
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
}
