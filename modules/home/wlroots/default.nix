{
  pkgs,
  osConfig,
  config,
  flake,
  perSystem,
  lib,
  ...
}: {
  imports = [
    flake.homeModules.alacritty
  ];
  programs = {
    fuzzel.enable = true;
    imv.enable = true;
    swaylock.enable = true;
    zathura.enable = true;
  };

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:";
    };
  };

  home.packages = with pkgs; [
    wireplumber
    brightnessctl
    nautilus
    gnome-clocks
    mpv
    #fractal
    bzmenu
    iwmenu
    pwmenu
    playerctl
  ];

  programs = {
    waybar = let
      inherit (osConfig.networking) hostName;
      fanQuery =
        if hostName == "neo"
        then "'to_entries[] | select(.key|startswith(\"dell\"))| .\"value\".\"fan1\".\"fan1_input\" | floor'"
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
      enable = true;
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
          #custom-ts {
            padding: 0 5px;
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
          modules-left = ["niri/workspaces" "cava"];
          modules-right = ["custom/ts" "systemd-failed-units" "custom/email" "custom/fan" "disk#root" "cpu" "memory" "network" "battery" "pulseaudio" "group/group-clock"];
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

          "custom/fan" = {
            exec =
              # bash
              ''
                rpm="$(${lib.getExe pkgs.lm_sensors} -j | ${lib.getExe pkgs.jq} ${fanQuery})"
                if [[ $rpm != "0" ]]; then
                  echo $rpm
                fi
              '';
            interval = 3;
            format = "󰈐 {}";
            hide-empty-text = true;
            on-click = "${lib.getExe config.programs.alacritty.package} --class hover -e ${lib.getExe config.programs.bottom.package} --default_widget_type temp -e";
          };

          "custom/ts" = {
            exec = "${lib.getExe pkgs.tailscale} status --peers --json | ${lib.getExe pkgs.jq} '.ExitNodeStatus.ID as $node_id | .Peer[] | select(.ID==$node_id) | .HostName' | tr -d '\"'";
            interval = 3;
            format = "󰲐 {}";
            hide-empty-text = true;
          };

          "custom/email" = {
            exec = lib.getExe perSystem.self.wb-email;
            interval = 5;
            format = "{}";
            on-click = "${lib.getExe' pkgs.systemd "systemctl"} --user start refresh-email.service";
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
            "interval" = 3600;
            "exec" = "${lib.getExe pkgs.wttrbar}";
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
              "half" = 50;
              "warning" = 30;
              "critical" = 15;
            };
            format-discharging = "{icon}";
            format-discharging-half = "{icon} {capacity}%";
            format-discharging-warning = "{icon} {capacity}%";
            format-discharging-critical = "󰂃 {capacity}%";
            format-charging = "󰚥 {capacity}%";
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
            on-click = "${lib.getExe config.programs.alacritty.package} --class hover -e ${lib.getExe config.programs.bottom.package} --default_widget_type cpu -e";
          };

          "memory" = {
            format = " {used:0.1f} GiB";
            tooltip-format = "Memory {used:0.1f} GiB / {total:0.1f} GiB\nSwap: {swapUsed:0.1f} GiB / {swapTotal:0.1f} GiB";
            interval = 3;
            on-click = "${lib.getExe config.programs.alacritty.package} --class hover -e ${lib.getExe config.programs.bottom.package} --default_widget_type mem -e";
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
        };
      };
    };
  };

  services = {
    wlsunset = {
      enable = true;
      latitude = "53.6";
      longitude = "-113.9";
      temperature.night = 1500;
    };

    mako = {
      enable = true;
      settings = {
        default-timeout = 30 * 1000;
      };
    };

    swayidle = let
      lock = "${lib.getExe pkgs.swaylock} -fF";
      screenTimeout = pkgs.writeShellScriptBin "screen-timeout" "${lib.getExe pkgs.niri} msg action power-off-monitors";

      lockScreenTimeout = pkgs.writeShellApplication {
        name = "lock-screen-timeout";

        runtimeInputs = with pkgs; [
          procps
          niri
          screenTimeout
        ];

        text = ''
          if pgrep swaylock
          then
            screen-timeout
          fi
        '';
      };
    in {
      enable = true;
      events.before-sleep = lock;
      timeouts = [
        {
          timeout = 5;
          command = lib.getExe lockScreenTimeout;
        }
        {
          timeout = 300;
          command = lock;
        }
        {
          timeout = 305;
          command = lib.getExe screenTimeout;
        }
        {
          timeout = 900;
          command = lib.getExe perSystem.self.sleep-on-battery;
        }
      ];
    };

    wob = {
      enable = true;
      settings."" = {
        anchor = "bottom";
        margin = 60;
      };
    };

    kanshi = {
      enable = true;
      profiles = {
      };
      settings = let
        main_screen = "Sharp Corporation 0x1453 Unknown";
        zenscreen = "Unknown ASUS MB16AC J6LMTF097058";
        lg_gaming = "LG Electronics LG QHD 0x00012B23";
        small_dell = "Dell Inc. DELL P2014H J6HFT3B9AK7L";
      in [
        {
          profile = {
            name = "laptop_only";
            outputs = [
              {
                criteria = main_screen;
                scale = 1.0;
                position = "0,0";
              }
            ];
          };
        }
        {
          profile = {
            name = "with_zenscreen";
            outputs = [
              {
                criteria = main_screen;
                scale = 1.0;
                position = "0,0";
              }
              {
                criteria = zenscreen;
                scale = 1.0;
                position = "1920,0";
              }
            ];
          };
        }
        {
          profile = {
            name = "docked";
            outputs = [
              {
                criteria = main_screen;
                scale = 1.25;
                position = "384,0";
              }
              {
                mode = "2560x1440@99.946";
                criteria = lg_gaming;
                scale = 1.0;
                position = "1920,0";
              }
            ];
          };
        }
        {
          profile = {
            name = "docked_triple";
            outputs = [
              {
                criteria = main_screen;
                scale = 1.25;
                position = "384,0";
              }
              {
                mode = "2560x1440@74.971";
                criteria = lg_gaming;
                scale = 1.0;
                position = "1920,0";
              }
              {
                criteria = small_dell;
                scale = 1.00;
                position = "4480,150";
              }
            ];
          };
        }
        {
          profile = {
            name = "office_desktop";
            outputs = [
              {
                criteria = lg_gaming;
                scale = 1.0;
                position = "0,0";
                mode = "2560x1440@144.000";
              }
              {
                criteria = small_dell;
                scale = 1.0;
                position = "2560,370";
              }
            ];
          };
        }
      ];
    };
  };
}
