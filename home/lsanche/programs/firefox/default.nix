{osConfig}: {
  inherit (osConfig.modules.desktop) enable;
  profiles.lsanche = {
    id = 0;
    isDefault = true;
    settings = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
  };
}
