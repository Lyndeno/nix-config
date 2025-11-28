{
  flake,
  osConfig,
  ...
}: {
  imports = [
    flake.homeModules.lsanche
  ];

  home.stateVersion = osConfig.system.stateVersion;
}
