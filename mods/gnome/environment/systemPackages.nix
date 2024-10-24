{pkgs}:
with pkgs;
  [
    gnome-tweaks
    gnome-firmware
    mission-center
    papers
    alpaca
  ]
  ++ (with gnomeExtensions; [
    appindicator
    dash-to-dock
    tailscale-qs
    caffeine
    dash-to-panel
    just-perfection
    blur-my-shell
    media-controls
    vitals
    battery-health-charging
  ])
