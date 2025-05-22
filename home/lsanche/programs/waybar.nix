{osConfig}: {
  inherit (osConfig.modules.niri) enable;
  systemd.enable = true;
  settings = {
    mainBar = {
      height = 36;
      modules-left = ["niri/workspaces" "cava"];
      modules-right = ["disk#root" "cpu" "memory" "network" "power-profiles-daemon" "battery" "pulseaudio" "idle_inhibitor" "clock"];
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

      "cava" = {
        #cava_config = "$XDG_CONFIG_HOME/cava/config";
        method = "pipewire";
        format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
        bars = 12;
        bar_delimiter = 0;
        hide_on_silence = true;
        monstercat = false;
        waves = false;
        stereo = false;
        sleep_timer = 5;
        framerate = 60;
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
        format-charging = "{icon}󰚥 {capacity}%";
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
          "activated" = "";
          "deactivated" = "";
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
      };

      "memory" = {
        format = " {used:0.1f}G ({percentage}%)";
        interval = 3;
      };

      "backlight" = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        format-icons = ["󰃜" "󰃛" "󰃚" "󰃞" "󰃟" "󰃠"];
      };

      "network" = {
        format-wifi = " ";
        format-ethernet = "󰈀  {bandwidthDownBits}";
        format-linked = "󰈀 {ifname} (No IP)";
        format-disconnected = "Disconnected ⚠";
        format-alt = "{ifname} = {ipaddr}/{cidr}   {bandwidthDownBits}  {bandwidthUpBits}";
        tooltip-format-wifi = "SSID = {essid}\nAddress = {ipaddr}\nBand {frequency} MHz\nUp = {bandwidthUpBits}\nDown = {bandwidthDownBits}\nStrength = {signalStrength}%";
        interval = 2;
        #on-click-right = "${commands.terminal} -e nmtui";
      };

      "pulseaudio" = {
        # "scroll-step": 1, // %, can be a float
        format = "{icon} {volume}%";
        format-bluetooth = "{icon} {volume}% {format_source} ";
        format-bluetooth-muted = "婢 {icon} {format_source}";
        format-muted = "󰖁";
        format-source = " {volume}%";
        format-source-muted = "";
        format-icons = {
          "headphone" = "";
          "hands-free" = "";
          "headset" = "";
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
