{
  haumea,
  lib,
  lsLib,
}: let
  # deadnix: skip
  loadCfg = folder: ({pkgs, ...} @ args:
    haumea.lib.load {
      src = folder;
      inputs = args;
      transformer = haumea.lib.transformers.liftDefault;
    });
in rec {
  mkSystem = {
    hostFolder,
    commonFolder,
    name,
    specialArgs ? {},
  }: let
    system = import (hostFolder + "/${name}/_localSystem.nix");

    hostCfg = loadCfg (hostFolder + "/${name}");
  in
    lib.nixosSystem {
      inherit system;
      modules = [
        hostCfg
        (loadCfg commonFolder)
        {networking.hostName = name;}
      ];
      inherit specialArgs;
    };

  makeNixos = {
    hostFolder,
    commonFolder,
    specialArgs ? {},
  }:
    builtins.listToAttrs
    (
      map
      (x: {
        name = x;
        value = mkSystem {
          inherit hostFolder commonFolder specialArgs;
          name = x;
        };
      })
      (lsLib.ls hostFolder)
    );
}
