{
  stateVersion,
  inputs,
  isDesktop,
  ...
}: let
  # deadnix: skip
  cfg = {pkgs, ...} @ args:
    inputs.haumea.lib.load {
      src = ./cfg;
      inputs =
        args
        // {
          inherit (inputs.nixpkgs) lib;
          inherit isDesktop inputs;
        };
      transformer = [
        inputs.haumea.lib.transformers.liftDefault
      ];
    };
in {
  imports = [cfg];

  home.stateVersion = stateVersion;
}
