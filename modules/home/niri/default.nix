{flake, ...}: {config, ...}: {
  imports = [
    flake.homeModules.wlroots
  ];
  services.hyprpaper.enable = true;
  home.file.".config/niri/config.kdl" = {
    text = import ./niri.nix {inherit config;};
  };
}
