{
  pkgs,
  perSystem,
  inputs,
  ...
}:
inputs.ci.lib.mkHydraCheck {
  inherit pkgs;
  specPackage = perSystem.self.hydra-spec;
  specFile = ../.hydra/spec.json;
}
