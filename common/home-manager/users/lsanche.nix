{homes}: {osConfig, ...}: {
  imports = [homes.lsanche];

  home.stateVersion = osConfig.system.stateVersion;
}
