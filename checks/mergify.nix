# Verifies the committed .mergify.yml matches the output of packages/mergify.nix.
# If this check fails, regenerate the config from the package and commit it.
{
  pkgs,
  perSystem,
  inputs,
  ...
}:
inputs.ci.lib.mkMergifyCheck {
  inherit pkgs;
  mergifyPackage = perSystem.self.mergify;
  mergifyFile = ../.mergify.yml;
}
