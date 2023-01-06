{config, pkgs, lib, ...}:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.sway}/bin/sway --config /etc/greetd/sway-config";
        user = "greeter";
      };
    };
  };

  environment.etc = {
    "greetd/sway-config".text = ''
      exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -s ${pkgs.gnome-themes-extra}/share/themes/Adwaita-dark/gtk-3.0/gtk.css ; swaymsg exit"
      bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot' \
      -b 'Suspend' 'systemctl suspend-then-hibernate' \
      -b 'Hibernate' 'systemctl hibernate'
      input "type:touchpad" {
        tap enabled
      }

      exec ${pkgs.swayidle}/bin/swayidle -w \
        timeout 30 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"'

      include /etc/sway/config.d/*
    '';
    "greetd/environments".text = ''
      sway
      zsh
      bash
    '';
  };
  
  security = {
    pam.services = {
      login.u2fAuth = false;
      greetd.u2fAuth = false;
      greetd.enableGnomeKeyring = true;
    };
    polkit.enable = true;
  };
}