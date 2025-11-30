{
  pkgs,
  osConfig,
  flake,
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
                rpm="$(${pkgs.lm_sensors}/bin/sensors -j | ${pkgs.jq}/bin/jq ${fanQuery})"
                if [[ $rpm != "0" ]]; then
                  echo $rpm
                fi
              '';
            interval = 3;
            format = "󰈐 {}";
            hide-empty-test = true;
          };

          "custom/ts" = {
            exec = "${pkgs.tailscale}/bin/tailscale status --peers --json | ${pkgs.jq}/bin/jq '.ExitNodeStatus.ID as $node_id | .Peer[] | select(.ID==$node_id) | .HostName' | tr -d '\"'";
            interval = 3;
            format = "󰲐 {}";
            hide-empty-test = true;
          };

          "custom/email" = {
            exec =
              # bash
              ''
                count="$(${pkgs.notmuch}/bin/notmuch count tag:inbox and tag:unread)"

                refreshState="$(${pkgs.systemd}/bin/systemctl --user is-active refresh-email.service)"
                if [[ $refreshState == "active" ]]; then
                  echo 󰑐 $count
                else
                  echo 󰇮 $count
                fi
              '';
            interval = 5;
            format = "{}";
            on-click = "${pkgs.systemd}/bin/systemctl --user start refresh-email.service";
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
            format-full = "";
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
            format-ethernet = "󰈀";
            format-linked = "󰈀 {ifname} (No IP)";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname} | {ipaddr}/{cidr} | {bandwidthDownBits} {bandwidthUpBits}";
            tooltip-format-wifi = "SSID: {essid}\nAddress: {ipaddr}\nBand {frequency} MHz\nUp: {bandwidthUpBits}\nDown: {bandwidthDownBits}\nStrength: {signalStrength}%\nGateway: {gwaddr}";
            tooltip-format-ethernet = "SSID: {essid}\nAddress: {ipaddr}\nUp: {bandwidthUpBits}\nDown: {bandwidthDownBits}\nGateway: {gwaddr}";
            interval = 2;
            on-click-right = "${pkgs.iwmenu}/bin/iwmenu --launcher fuzzel";
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
      lock = "${pkgs.swaylock}/bin/swaylock -fF";
      runInShell = name: cmd: "${pkgs.writeShellScript "${name}" ''${cmd}''}";
      screenTimeout = "${pkgs.niri}/bin/niri msg action power-off-monitors";
      pgrep = "${pkgs.procps}/bin/pgrep";
      cut = "${pkgs.coreutils-full}/bin/cut";
      systemctl = "${pkgs.systemd}/bin/systemctl";
      lockScreenTimeout = runInShell "swayidle-lockscreen-timeout" ''
        if ${pgrep} swaylock
        then
          ${screenTimeout}
        fi
      '';
      idleSleep = runInShell "swayidle-sleep-when-idle" ''
        BAT_STATUS=$(${pkgs.acpi}/bin/acpi -a | ${cut} -d" " -f3 | ${cut} -d- -f1)
        if [ "$BAT_STATUS" = "off" ]
        then
          ${systemctl} suspend-then-hibernate
        fi
      '';
    in {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = lock;
        }
      ];
      timeouts = [
        {
          timeout = 5;
          command = lockScreenTimeout;
        }
        {
          timeout = 300;
          command = lock;
        }
        {
          timeout = 305;
          command = screenTimeout;
        }
        {
          timeout = 900;
          command = idleSleep;
        }
      ];
    };

    polkit-gnome.enable = true;

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
