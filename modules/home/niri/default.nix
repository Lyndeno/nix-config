{
  config,
  flake,
  ...
}: {
  imports = [
    flake.homeModules.wlroots
  ];
  home.file.".config/niri/config.kdl" = {
    text = import ./niri.nix {inherit config;};
  };
}
