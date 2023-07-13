{pkgs}:
with pkgs;
  [
    wally-cli # for moonlander
    brightnessctl # for brightness control
    gnome.gnome-tweaks
    gnome-firmware

    ettercap
    ethtool
    bettercap

    kdiskmark
  ]
  ++ (with gnomeExtensions; [
    appindicator
    #dash-to-panel
    dash-to-dock
    tailscale-status
    caffeine
  ])
