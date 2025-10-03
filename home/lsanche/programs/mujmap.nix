{
  inputs,
  pkgs,
  osConfig,
}: {
  inherit (osConfig.modules.desktop) enable;
  package = inputs.mujmap.packages.${pkgs.system}.default;
}
