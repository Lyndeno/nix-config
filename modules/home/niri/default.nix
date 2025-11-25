{
  config,
  flake,
  ...
}: {
  imports = [
    flake.homeModules.wlroots
  ];
  file.".config/niri/config.kdl" = {
    text = import ./niri.nix {inherit config;};
  };
}
