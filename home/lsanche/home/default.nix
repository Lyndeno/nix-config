{osConfig}: {
  username = "lsanche";
  homeDirectory = "/home/lsanche";
  enableNixpkgsReleaseCheck = true;
  inherit (osConfig.system) stateVersion;
}
