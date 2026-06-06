# Generates the Mergify config from the flake's checks. The committed copy lives at
# .mergify.yml and is validated against this output by checks/mergify.nix.
{
  pkgs,
  pname,
  flake,
  inputs,
  ...
}:
inputs.ci.lib.mkMergifyConfig {
  inherit pkgs;
  inherit (flake) checks;
  name = pname;
  projectName = "nix-config";
}
