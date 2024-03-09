{
  haumea,
  lib,
}: let
  # deadnix: skip
  loadFolder = folder: ({pkgs, ...} @ args:
    haumea.lib.load {
      src = folder;
      inputs = args;
      transformer = haumea.lib.transformers.liftDefault;
    });

  ls = folder: (builtins.attrNames (builtins.readDir folder));

  mods = modFolder: import ./modules.nix {inherit lib modFolder loadFolder;};
in rec {
  inherit loadFolder;
  mkSystem = {
    hostFolder,
    commonFolder,
    modFolder,
    name,
    specialArgs ? {},
  }: let
    system = import (hostFolder + "/${name}/_localSystem.nix");

    hostCfg = loadFolder (hostFolder + "/${name}");
  in
    lib.nixosSystem {
      inherit system;
      modules = [
        hostCfg
        (loadFolder commonFolder)
        (mods modFolder)
        {networking.hostName = name;}
      ];
      inherit specialArgs;
    };

  makeNixos = {
    hostFolder,
    commonFolder,
    modFolder,
    specialArgs ? {},
  }:
    builtins.listToAttrs
    (
      map
      (x: {
        name = x;
        value = mkSystem {
          inherit hostFolder commonFolder modFolder specialArgs;
          name = x;
        };
      })
      (ls hostFolder)
    );
}
