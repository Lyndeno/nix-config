{config, lib, pkgs, inputs, ...}:

with lib;

let
  cfg = config.modules.desktop;
in
{
  config = mkIf ((cfg.environment == "sway") && cfg.enable) {
    programs.gnupg.agent.pinentryFlavor = "gnome3";

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
    services.gnome.gnome-keyring.enable = true;
    services.gvfs.enable = true;

    xdg.portal = {
      wlr.enable = true;
      gtkUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    programs = {
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
          swaylock
          swayidle
          wl-clipboard
          mako
          alacritty
          bemenu
          slurp
          grim
          acpi
        ];
      };
      seahorse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gnome.nautilus
    ];

    home-manager.users.lsanche = let
      swaylock-config = pkgs.callPackage ./swaylock.nix { thm = config.scheme; };
      commands = {
        lock = "${pkgs.swaylock}/bin/swaylock -C ${swaylock-config}";
      };
    in rec {

      services.wlsunset = {
        enable = true;
        latitude = "53.6";
        longitude = "-113.3";
      };

      programs.waybar = {
        enable = true;
        package = pkgs.waybar.override { withMediaPlayer = true; };
      } // import ./sway/waybar {
        inherit pkgs lib;
        cssScheme = builtins.readFile (config.scheme inputs.base16-waybar);
        mediaplayerCmd = "${programs.waybar.package}/bin/waybar-mediaplayer.py";
      };
      wayland.windowManager.sway = with config.scheme.withHashtag; {
          enable = true;
          wrapperFeatures.gtk = true;
          package = null;
          config = (import ./common.nix {
            inherit commands pkgs lib;
            wallpaper = with config.modules.desktop.mainResolution; "${import ./wallpaper.nix { inherit config pkgs; } { inherit height width; }}";
            thm = config.scheme;
            # TODO: We use this to access our set terminal packages. Pass through that instead
            homeCfg = config.home-manager.users.lsanche;
          }) // {
            colors = {
              background = base07;
              focused = {
                border = base05;
                background = base0D;
                text = base00;
                indicator = base0D;
                childBorder = base0D;
              };
              focusedInactive = {
                border = base01;
                background = base01;
                text = base05;
                indicator = base03;
                childBorder = base01;
              };
              unfocused = {
                border = base01;
                background = base00;
                text = base05;
                indicator = base01;
                childBorder = base01;
              };
              urgent = {
                border = base08;
                background = base08;
                text = base00;
                indicator = base08;
                childBorder = base08;
              };
              placeholder = {
                border = base00;
                background = base00;
                text = base05;
                indicator = base00;
                childBorder = base00;
              };
            };
          };
      };

      services.swayidle = {
        enable = true;
        events = [
          { event = "before-sleep"; command = "${pkgs.playerctl}/bin/playerctl pause; if ! pgrep swaylock; then ${commands.lock}; fi"; }
        ];
        timeouts = let
          runInShell = name: cmd: "${pkgs.writeShellScript "${name}" ''${cmd}''}";
          screenOn = runInShell "swayidle-screen-on" ''
            swaymsg "output * dpms on"
          '';
        in
          [
          {
            timeout = 30;
            command = runInShell "swayidle-lockscreen-timeout" ''
              if pgrep swaylock
              then
                swaymsg "output * dpms off"
              fi
            '';
            resumeCommand = screenOn;
          }
          {
            timeout = 300;
            command = "${commands.lock}";
          }
          {
            timeout = 310;
            command = runInShell "swayidle-screen-off" ''
              swaymsg "output * dpms off"
            '';
            #resumeCommand = runInShell "swayidle-screen-on" ''
            #  swaymsg "output * dpms on"
            #'';
            resumeCommand = screenOn;
          }
          {
            timeout = 900;
            command = "${pkgs.writeShellScript "swayidle-sleep-when-idle" ''
              if [ $(${pkgs.acpi}/bin/acpi -a | cut -d" " -f3 | cut -d- -f1) = "off" ]
              then
                systemctl suspend-then-hibernate
              fi
            ''}";
          }
        ];
      };

      # Referenced https://github.com/stacyharper/base16-mako/blob/master/templates/default.mustache
      programs.mako = with config.scheme.withHashtag; {
          enable = true;
          anchor = "bottom-right";
          backgroundColor = base00;
          borderColor = base0D;
          textColor = base05;
          borderRadius = 5;
          borderSize = 2;
          defaultTimeout = 10000;
          font = "CaskcaydiaCove Nerd Font 12";
          groupBy = "summary";
          layer = "overlay";
      };
    };
  };
}
