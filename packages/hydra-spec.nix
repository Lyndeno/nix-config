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
