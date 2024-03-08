{
  lib,
  haumea,
  modFolder,
  lsLib,
}: let
  modNames = lsLib.lsDirs modFolder;

  getMod = name: ({
      # deadnix: skip
      pkgs,
      # deadnix: skip
      config,
      ...
    } @ args:
      haumea.lib.load {
        src = modFolder + "/${name}";
        inputs = args;
        transformer = haumea.lib.transformers.liftDefault;
      });
in
  {
    config,
    lib,
    # deadnix: skip
    pkgs,
    # deadnix: skip
    inputs,
    ...
  } @ args: {
    options.mods = builtins.listToAttrs (
      map
      (
        x: {
          name = x;
          value = {enable = lib.mkEnableOption "${x} mod";};
        }
      )
      modNames
    );
    config = lib.mkMerge (
      map
      (
        x: lib.mkIf config.mods.${x}.enable ((getMod x) args)
      )
      modNames
    );
  }
