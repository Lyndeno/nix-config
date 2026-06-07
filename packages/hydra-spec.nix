# Builds the Hydra jobset spec JSON. The committed copy lives at .hydra/spec.json
# and is validated against this output by checks/hydra-spec.nix (drift detection).
{
  pkgs,
  pname,
  inputs,
  ...
}:
inputs.ci.lib.mkHydraSpec {
  inherit pkgs;
  name = pname;
  owner = "Lyndeno";
  repo = "nix-config";
}
