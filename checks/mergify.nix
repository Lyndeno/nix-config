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
