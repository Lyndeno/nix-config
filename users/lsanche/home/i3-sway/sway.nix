{
  config,
  pkgs,
  lib,
  isDesktop,
  desktopEnv,
  ...
}: let
  commands = {
    lock = "${pkgs.swaylock}/bin/swaylock -f";
    terminal = "${pkgs.alacritty}/bin/alacritty";
    menu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu=\"${pkgs.bemenu}/bin/bemenu -i ${config.home.sessionVariables.BEMENU_OPTS} -c -H 25 -W 0.3\"";
  };
  fix-xwayland = pkgs.writeShellScript "fix-xwayland" ''
    PRIM_DISPLAY=$(${pkgs.xorg.xrandr}/bin/xrandr | ${pkgs.gnugrep}/bin/grep 2560x1440+ | ${pkgs.gawk}/bin/awk '{print $1}')

    ${pkgs.xorg.xrandr}/bin/xrandr --output $PRIM_DISPLAY --primary && ${pkgs.libnotify}/bin/notify-send " XWayland" "Primary X display set to $PRIM_DISPLAY"
  '';
  isSway = (desktopEnv == "sway") && isDesktop;
in {
  config = lib.mkIf isSway {
    services.udiskie.enable = true;
    services.wlsunset = {
      enable = true;
      latitude = "53.6";
      longitude = "-113.3";
    };

    programs.waybar =
      {
        enable = true;
        package = pkgs.waybar.override {withMediaPlayer = true;};
      }
      // import ./sway/waybar {
        inherit pkgs lib commands config;
        mediaplayerCmd = "${config.programs.waybar.package}/bin/waybar-mediaplayer.py";
      };
    wayland.windowManager.sway = with config.scheme.withHashtag; let
      inherit (wayland.windowManager.sway.config) modifier;
    in {
      enable = true;
      wrapperFeatures.gtk = true;
      package = null;
      config =
        (import ./common.nix {
          inherit config commands pkgs lib;
          thm = config.lib.stylix.colors;
          # TODO: We use this to access our set terminal packages. Pass through that instead
          homeCfg = config.home-manager.users.lsanche;
          extraKeybindings = {
            "print" = "exec --no-startup-id ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.wl-clipboard}/bin/wl-paste > ~/Pictures/$(${pkgs.busybox}/bin/date +'screenshot_%Y-%m-%d-%H%M%S.png')";
            "${modifier}+Shift+x" = "exec ${fix-xwayland}";
          };
          extraStartup = [
            {command = "dbus-update-activation-environment WAYLAND_DISPLAY";}
          ];
        })
        // {
          bars = [];
          window.commands = [
            {
              criteria = {
                title = "^Picture-in-Picture$";
                app_id = "firefox";
              };
              command = "floating enable, move position 877 450, sticky enable";
            }
            {
              criteria = {
                title = "Firefox — Sharing Indicator";
                app_id = "firefox";
              };
              command = "floating enable, move position 877 450";
            }
          ];
          input = {
            "type:touchpad" = {
              tap = "enabled";
              natural_scroll = "enabled";
              scroll_factor = "0.2";
            };
          };
        };
    };

    programs.mako = {
      enable = true;
      anchor = "bottom-right";
      borderRadius = 5;
      borderSize = 2;
      defaultTimeout = 10000;
      groupBy = "summary";
      layer = "overlay";
    };
    services.swayidle = let
      runInShell = name: cmd: "${pkgs.writeShellScript "${name}" ''${cmd}''}";
      pgrep = "${pkgs.procps}/bin/pgrep";
      cut = "${pkgs.coreutils-full}/bin/cut";
      systemctl = "${pkgs.systemd}/bin/systemctl";
      screenOn = runInShell "swayidle-screen-on" ''
        ${pkgs.sway}/bin/swaymsg "output * dpms on"
      '';
      lockScreenTimeout = runInShell "swayidle-lockscreen-timeout" ''
        if ${pgrep} swaylock
        then
          ${pkgs.sway}/bin/swaymsg "output * dpms off"
        fi
      '';
      screenTimeout = runInShell "swayidle-screen-off" ''
        ${pkgs.sway}/bin/swaymsg "output * dpms off"
      '';
      idleSleep = runInShell "swayidle-sleep-when-idle" ''
        BAT_STATUS=$(${pkgs.acpi}/bin/acpi -a | ${cut} -d" " -f3 | ${cut} -d- -f1)
        if [ "$BAT_STATUS" = "off" ]
        then
          ${systemctl} suspend-then-hibernate
        fi
      '';
      beforeSleep = runInShell "swayidle-before-sleep" ''
        ${pkgs.playerctl}/bin/playerctl pause
        if ! ${pgrep} swaylock
          then ${commands.lock}
        fi
      '';
    in {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = beforeSleep;
        }
      ];
      timeouts = [
        {
          timeout = 30;
          command = lockScreenTimeout;
          resumeCommand = screenOn;
        }
        {
          timeout = 180;
          command = "${commands.lock}";
        }
        {
          timeout = 200;
          command = screenTimeout;
          #resumeCommand = runInShell "swayidle-screen-on" ''
          #  swaymsg "output * dpms on"
          #'';
          resumeCommand = screenOn;
        }
        {
          timeout = 900;
          command = idleSleep;
        }
      ];
    };
    systemd.user = {
      services.wob = {
        Unit = {
          Description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
          Documentation = ["man:wob(1)"];
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };
        Service = {
          StandardInput = "socket";
          ExecStart = "${pkgs.wob}/bin/wob";
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
      sockets.wob = {
        Socket = {
          ListenFIFO = "%t/wob.sock";
          SocketMode = "0600";
          RemoveOnStop = "on";
          FlushPending = "yes";
        };
        Install = {
          WantedBy = ["sockets.target"];
        };
      };
    };
    home.file.wobConfig = with config.lib.stylix.colors; {
      target = ".config/wob/wob.ini";
      text = ''
        bar_color = ${base07}FF
        border_color = ${base07}FF
        background_color = ${base01}FF
        anchor = bottom
        margin = 30
      '';
    };
  };
}
