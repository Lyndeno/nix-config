_lib: inputs: commonModules:
with inputs.nixos-hardware.nixosModules; let
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
        (inputs.haumea.lib.transformers.hoistLists "_imports" "imports")
      ];
    };
in
  [
    cfg
    common-gpu-amd
    common-cpu-amd
    common-cpu-amd-pstate
  ]
  ++ commonModules
