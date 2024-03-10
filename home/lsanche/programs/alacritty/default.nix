{osConfig}: {
  inherit (osConfig.mods.desktop) enable;
  # colours and font managed by stylix
  settings = {
    window = {
      padding = {
        x = 12;
        y = 12;
      };
      dynamic_padding = true;
    };
    mouse.hide_when_typing = true;
  };
}
