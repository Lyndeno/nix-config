{
  stateVersion,
  inputs,
  lsLib,
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
        };
      transformer = [
        inputs.haumea.lib.transformers.liftDefault
      ];
    };
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  # Pass more args to "import"
  _module.args = {
    inherit inputs lsLib;
  };
  # Import all files in "home"
  imports = (lsLib.lsPaths ./home) ++ [cfg];

  home.stateVersion = stateVersion;
}
