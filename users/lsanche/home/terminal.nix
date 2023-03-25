{
  isDesktop,
  lib,
  ...
}: {
  programs.alacritty = lib.mkIf isDesktop {
    enable = true;
    # colours and font managed by stylix
    settings = {
      window = {
        padding = {
          x = 12;
          y = 12;
        };
        dynamic_padding = true;
        opacity = 0.95;
      };
      mouse.hide_when_typing = true;
    };
  };
}
