{
  flake,
  osConfig,
  ...
}: {
  imports = with flake.homeModules; [
    lsanche
    alacritty
    niri
    desktop
    development
    email
    nixvim
    shell
  ];

  home.stateVersion = osConfig.system.stateVersion;
}
