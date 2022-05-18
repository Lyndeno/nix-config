{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.home.modules.desktop;
  commands = {
    lock = "${pkgs.swaylock-effects}/bin/swaylock";
  };
in
{
  options = {
      home = {
        modules = {
          desktop = {
              enable = mkOption {type = types.bool; default = false; };
          };
        };
      };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
        spotify
        zathura
        signal-desktop
        spotify
        discord
        libreoffice-qt
        imv
        #avizo
        #pamixer
    ];

    programs.alacritty = {
        enable = true;
        settings = {
        font = {
            size = 11;
            normal = {
            family = "CaskaydiaCove Nerd Font Mono";
            style = "Regular";
            };
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
        colors = {
            primary = {
            foreground = "#ffffff";
            background = "#191919";
            };
            normal = {
            black = "#171421";
            red =   "#c01c28";
            green = "#26a269";
            yellow = "#e3d44b";
            blue =  "#12488b";
            magenta = "#a347ba";
            cyan =  "#2aa1b3";
            white = "#d0cfcc";
            };
            bright = {
            black = "#5e5c64";
            red =   "#f66151";
            green = "#33d17a";
            yellow = "#e9ad0c";
            blue =  "#2a7bde";
            magenta = "#c061cb";
            cyan =  "#33c7de";
            white = "#ffffff";
            };
        };
        };
    };
  };
}
