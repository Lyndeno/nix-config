{pkgs}:
with pkgs;
  [
    wally-cli # for moonlander
    brightnessctl # for brightness control
    gnome.gnome-tweaks
    gnome-firmware
    mission-center

    ettercap
    ethtool
    bettercap

    kdiskmark
  ]
  ++ (with gnomeExtensions; [
    appindicator
    #dash-to-panel
    dash-to-dock
    #tailscale-status
    tailscale-qs
    caffeine
    dash-to-panel
    just-perfection
    blur-my-shell
  ])
