{
  inputs,
  pkgs,
  lib,
  flake,
  config,
  ...
}: let
  moduleConfig = inputs.haumea.lib.load {
    src = ./mod;
    inputs = {inherit inputs pkgs lib flake config;};
    transformer = inputs.haumea.lib.transformers.liftDefault;
  };
in {
  imports = [
    moduleConfig
  ];
}
