{
  osConfig,
  pkgs,
  config,
  lib,
}: let
  inherit (osConfig.networking) hostName;
  fanQuery =
    if hostName == "neo"
    then "'.\"dell_smm-isa-0000\".\"fan1\".\"fan1_input\" | floor'"
    else if hostName == "morpheus"
    then "'.\"nct6798-isa-0290\".\"fan1\".\"fan1_input\" | floor'"
    else "";

  sensitivity =
    if hostName == "neo"
    then 18
    else 10;

  framerate =
    if hostName == "morpheus"
    then 144
    else 60;
in {
  inherit (osConfig.modules.niri) enable;
  systemd.enable = true;
  style =
    # css
    ''
      #custom-fan {
        padding: 0 5px;
      }
      #custom-email {
        padding: 0 5px;
      }
      #systemd-failed-units {
        padding: 0 5px;
      }
      #power-profiles-daemon {
        padding: 0 5px;
      }
    '';
  settings = {
    mainBar = {
      height = 36;
      modules-left = ["niri/workspaces" "cava"];
      modules-right = ["systemd-failed-units" "custom/email" "custom/fan" "disk#root" "cpu" "memory" "network" "group/group-power" "pulseaudio" "group/group-clock"];
      "disk#root" = {
        interval = 30;
        format = "󰋊 {percentage_free}%";
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

      "custom/fan" = {
        exec = "${pkgs.lm_sensors}/bin/sensors -j | ${pkgs.jq}/bin/jq ${fanQuery}";
        interval = 3;
        format = "󰈐 {}";
      };

      "custom/email" = {
        exec = "${pkgs.notmuch}/bin/notmuch count tag:inbox and tag:unread";
        interval = 15;
        format = "󰇮 {}";
      };

      "group/group-power" = {
        orientation = "inherit";
        drawer = {
          transition-duration = 500;
          transition-left-to-right = false;
        };
        modules = [
          (lib.mkIf (hostName == "neo") "battery")
          "power-profiles-daemon"
          "idle_inhibitor"
        ];
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
        ];
      };

      "custom/weather" = {
        "format" = "{}°";
        "tooltip" = true;
        "interval" = 3600;
        "exec" = "${pkgs.wttrbar}/bin/wttrbar";
        "return-type" = "json";
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
          "warning" = 30;
          "critical" = 15;
        };
        format-discharging = "{icon} {capacity}%";
        format-charging = "󰚥 {capacity}%";
        format-full = "󱐋";
        format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰂀" "󰂁" "󰂂" "󰁹"];
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
        on-click = "${pkgs.resources}/bin/resources -t cpu";
      };

      "memory" = {
        format = " {used:0.1f}G ({percentage}%)";
        tooltip-format = "{used:0.1f} GiB / {total:0.1f} GiB\n{swapUsed:0.1f} GiB / {swapTotal:0.1f} GiB";
        interval = 3;
        on-click = "${pkgs.resources}/bin/resources -t memory";
      };

      "backlight" = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        format-icons = ["󰃜" "󰃛" "󰃚" "󰃞" "󰃟" "󰃠"];
      };

      "network" = {
        format-wifi = "{icon}";
        format-ethernet = "󰈀 {bandwidthDownBits}";
        format-linked = "󰈀 {ifname} (No IP)";
        format-disconnected = "Disconnected ⚠";
        format-alt = "{ifname} | {ipaddr}/{cidr} | {bandwidthDownBits} {bandwidthUpBits}";
        tooltip-format-wifi = "SSID = {essid}\nAddress = {ipaddr}\nBand {frequency} MHz\nUp = {bandwidthUpBits}\nDown = {bandwidthDownBits}\nStrength = {signalStrength}%";
        interval = 2;
        on-click-right = "${config.programs.alacritty.package}/bin/alacritty --class hover -e nmtui";
        format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
      };

      "pulseaudio" = {
        # "scroll-step": 1, // %, can be a float
        format = "{icon} {volume}%";
        format-bluetooth = "{icon} {volume}%";
        format-bluetooth-muted = "{icon} 󰖁";
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
    };
  };
}
