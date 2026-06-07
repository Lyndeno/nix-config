# Verifies the committed .hydra/spec.json matches the output of packages/hydra-spec.nix.
# If this check fails, regenerate the spec from the package and commit it.
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
