{
  inputs,
  pkgs,
}: {
  enable = true;
  package = inputs.mujmap.packages.${pkgs.system}.default;
}
