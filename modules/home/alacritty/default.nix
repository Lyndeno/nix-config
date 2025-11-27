{
  programs.alacritty = {
    enable = true;
    # colours and font managed by stylix
    settings = {
      window = {
        padding = {
          x = 12;
          y = 12;
        };
        dynamic_padding = true;
        decorations = "None";
      };
      mouse.hide_when_typing = true;
      keyboard.bindings = [
        {
          key = "Space";
          mods = "Control";
          chars = "\\u0000";
        }
      ];
    };
  };
}
