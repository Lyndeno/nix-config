{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}: {
  programs = {
    waybar = let
      inherit (osConfig.networking) hostName;

      sensitivity =
        if hostName == "neo"
        then 18
        else 10;

      framerate =
        if hostName == "morpheus"
        then 144
        else 60;

      # Run a command in a floating "hover" terminal (waybar on-click).
      hover = cmd: "${lib.getExe config.programs.alacritty.package} --class hover -e ${cmd}";
      # Open bottom on a given default widget in a hover terminal.
      btm = widget: hover "${lib.getExe config.programs.bottom.package} --default_widget_type ${widget} -e";
    in {
      enable = true;
      systemd.enable = true;
      # mkAfter keeps our overrides ordered after Stylix's injected base CSS
      # (both are default priority, so this preserves the intended cascade).
      style =
        lib.mkAfter
        # css
        ''
          #custom-fan {
            padding: 0 5px;
          }
          #custom-email {
            padding: 0 5px;
          }
          #custom-update {
            padding: 0 5px;
          }
          #custom-update.update-available {
            color: @base0A;
          }
          #custom-update.error {
            color: @base08;
          }
          #custom-ts {
            padding: 0 5px;
          }
          #privacy {
            padding: 0 5px;
            background-color: @base08;
            border-radius: 10px;
          }
          #systemd-failed-units {
            padding: 0 5px;
          }
          #power-profiles-daemon {
            padding: 0 5px;
          }
          #battery.warning:not(.charging) {
            color: @base0A;
          }
          #battery.critical:not(.charging) {
            color: @base08;
          }
        '';
      settings = {
        mainBar = {
          height = 36;
          modules-left = ["niri/workspaces" (lib.mkIf (hostName != "neo") "cava")];
          modules-center = ["mpris" "custom/cast"];
          modules-right = [(lib.mkIf (hostName == "neo" || hostName == "morpheus") "custom/ts") (lib.mkIf config.programs.aerc.enable "custom/email") "custom/update" "systemd-failed-units" "privacy" "custom/fan" "disk#root" "cpu" "memory" "network" "battery" "pulseaudio" "group/group-clock"];
          "disk#root" = {
            interval = 30;
            format = "";
            format-high = "󰋊 {percentage_free}%";
            format-warning = "󰋊 {percentage_free}%";
            format-critical = "󰋊 {percentage_free}%";
            path = "/";
            states = {
              "warning" = 80;
              "high" = 90;
              "critical" = 95;
            };
          };

          "systemd-failed-units" = {
            hide-on-ok = true;
            format = "󰋼 {nr_failed}";
          };

          "custom/email" = lib.mkIf config.programs.aerc.enable {
            exec = "${lib.getExe pkgs.fastmail-unread} ${osConfig.age.secrets.fastmail-jmap.path}";
            interval = 60;
            return-type = "json";
            format = "󰇮 {}";
            hide-empty-text = true;
            on-click = hover "aerc";
          };

          "custom/update" = {
            exec = lib.getExe pkgs.update-available;
            interval = 300;
            return-type = "json";
            format = "{icon}";
            format-icons = {
              "update-available" = "󰚰";
              "up-to-date" = "";
              "error" = "";
            };
            # Launch as a transient unit so it lives in its own cgroup and
            # survives waybar restarts (which would otherwise kill children).
            on-click = "${pkgs.systemd}/bin/systemd-run --user --quiet --collect -- ${hover "${lib.getExe pkgs.update-system-hold}"}";
          };

          "custom/cast" = {
            exec = lib.getExe pkgs.wb-cast;
            restart-interval = 5;
            format = "󰐮 {}";
            return-type = "json";
            hide-empty-text = true;
          };

          "custom/fan" = {
            exec = lib.getExe pkgs.wb-fan;
            interval = 3;
            format = "{}";
            return-type = "json";
            hide-empty-text = true;
            on-click = btm "temp";
          };

          "custom/ts" = lib.mkIf (hostName == "neo" || hostName == "morpheus") {
            exec = lib.getExe pkgs.wb-ts;
            interval = 3;
            format = "󰲐 {}";
            hide-empty-text = true;
          };

          "group/group-clock" = {
            orientation = "inherit";
            drawer = {
              transition-duration = 500;
              transition-left-to-right = false;
            };
            modules = [
              "clock"
              "custom/weather"
              "power-profiles-daemon"
              "idle_inhibitor"
            ];
          };

          "custom/weather" = {
            "format" = "{}°";
            "tooltip" = true;
            "interval" = 600;
            "exec" = "${lib.getExe pkgs.wttrbar} --nerd";
            "return-type" = "json";
            on-click = hover "${lib.getExe pkgs.terminal-weather}";
          };

          "cava" = {
            inherit framerate sensitivity;
            #cava_config = "$XDG_CONFIG_HOME/cava/config";
            method = "pipewire";
            format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
            bars = 24;
            bar_delimiter = 0;
            hide_on_silence = true;
            monstercat = false;
            waves = false;
            stereo = false;
            sleep_timer = 5;
            autosens = 0;
            lower_cutoff_freq = 50;
            higher_cutoff_freq = 10000;
            noise_reduction = 0.25;
            actions = {
              on-click-right = "mode";
            };
          };

          "battery" = {
            interval = 5;
            states = {
              "half" = 50;
              "warning" = 30;
              "critical" = 15;
            };
            format-discharging = "{icon}";
            format-discharging-half = "{icon} {capacity}%";
            format-discharging-warning = "{icon} {capacity}%";
            format-discharging-critical = "󰂃 {capacity}%";
            format-charging = "󰚥 {capacity}%";
            format-plugged = "";
            format-full = "";
            format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰂀" "󰂁" "󰂂" "󰁹"];
            tooltip-format = "Charge: {capacity}%\n{timeTo}";
          };

          "clock" = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format = "{:%I:%M %p}";
            format-alt = "{:%Y-%m-%d}";
          };

          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              "activated" = "󰅶";
              "deactivated" = "󰾪";
            };
          };

          "tray" = {
            icon-size = 12;
            spacing = 3;
          };

          "cpu" = {
            format = " {usage}%";
            tooltip = true;
            interval = 3;
            on-click = btm "cpu";
          };

          "memory" = {
            format = " {used:0.1f} GiB";
            tooltip-format = "Memory {used:0.1f} GiB / {total:0.1f} GiB\nSwap: {swapUsed:0.1f} GiB / {swapTotal:0.1f} GiB";
            interval = 3;
            on-click = btm "mem";
          };

          "backlight" = {
            device = "intel_backlight";
            format = "{icon} {percent}%";
            format-icons = ["󰃜" "󰃛" "󰃚" "󰃞" "󰃟" "󰃠"];
          };

          "network" = {
            format-wifi = "{icon}";
            format-ethernet = "󰈀";
            format-linked = "󰈀 {ifname} (No IP)";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname} | {ipaddr}/{cidr} | {bandwidthDownBits} {bandwidthUpBits}";
            tooltip-format-wifi = "SSID: {essid}\nAddress: {ipaddr}\nBand {frequency} MHz\nUp: {bandwidthUpBits}\nDown: {bandwidthDownBits}\nStrength: {signalStrength}%\nGateway: {gwaddr}";
            tooltip-format-ethernet = "SSID: {essid}\nAddress: {ipaddr}\nUp: {bandwidthUpBits}\nDown: {bandwidthDownBits}\nGateway: {gwaddr}";
            interval = 2;
            on-click-right = "${lib.getExe pkgs.iwmenu} --launcher fuzzel";
            format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
          };

          "pulseaudio" = {
            # "scroll-step": 1, // %, can be a float
            format = "{icon} {volume}%";
            format-muted = "󰖁";
            format-source = " {volume}%";
            format-source-muted = "";
            format-icons = {
              "headphone" = "󰋋";
              "hands-free" = "󰋋";
              "headset" = "󰋋";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = ["󰕿" "󰖀" "󰕾"];
            };
          };

          "power-profiles-daemon" = {
            "format" = "{icon}";
            "tooltip-format" = "Power profile: {profile}\nDriver: {driver}";
            "tooltip" = true;
            "format-icons" = {
              "default" = "";
              "performance" = "";
              "balanced" = "";
              "power-saver" = "";
            };
          };

          "privacy" = {
            icon-size = 16;
            modules = [
              {
                type = "screenshare";
                icon-name = "display-projector-symbolic";
              }
              {
                type = "audio-in";
                icon-name = "microphone-sensitivity-high-symbolic";
              }
            ];
            ignore = [
              {
                type = "audio-in";
                name = "cava";
              }
            ];
          };

          "mpris" = {
            format = "{player_icon} {dynamic}";
            format-paused = "{status_icon} <i>{dynamic}</i>";
            player-icons = {
              "spotify" = "󰓇";
              "default" = "";
              "firefox" = "󰈹";
            };
            dynamic-order = [
              "artist"
              "title"
            ];
            status-icons = {
              paused = "󰏦";
            };
          };
        };
      };
    };
  };
}
