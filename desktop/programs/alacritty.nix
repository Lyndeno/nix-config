{
  config,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.lsanche.programs.alacritty = {
    enable = true;
    # colours and font managed by stylix
    settings = {
      font = {
        size = 11;
      };
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
