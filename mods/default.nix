{
  config,
  lib,
  lsLib,
  inputs,
  pkgs,
  ...
}: let
  modNames = lsLib.lsDirs ./.;

  # deadnix: skip
  getMod = name: ({pkgs, ...} @ args:
    inputs.haumea.lib.load {
      src = ./${name};
      inputs =
        args
        // {
          inherit (inputs.nixpkgs) lib;
        };
      transformer = inputs.haumea.lib.transformers.liftDefault;
    });
in {
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
      x: lib.mkIf config.mods.${x}.enable ((getMod x) {inherit pkgs;})
    )
    modNames
  );
}
