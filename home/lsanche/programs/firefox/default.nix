{osConfig}: {
  inherit (osConfig.modules.desktop) enable;
  profiles.lsanche = {
    id = 0;
    isDefault = true;
  };
}
