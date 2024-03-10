{osConfig}: {
  inherit (osConfig.mods.desktop) enable;
  profiles.lsanche = {
    id = 0;
    isDefault = true;
  };
}
