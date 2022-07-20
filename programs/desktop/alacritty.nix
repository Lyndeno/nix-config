{config, pkgs, inputs, ...}:
{
  home-manager.users.lsanche.programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = 11;
          #normal = {
          #  family = "CaskaydiaCove Nerd Font Mono";
          #  style = "Regular";
          #};
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
        #import = [
        #  (config.scheme { templateRepo = inputs.base16-alacritty; target = "default-256"; })
        #];
      };
  };
}
