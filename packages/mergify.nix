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
