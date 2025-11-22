{pkgs}: {
  excludePackages = with pkgs; [
    gnome-tour
    gnome-text-editor
    evince
    epiphany
    gnome-font-viewer
    totem
    gnome-music
    gnome-characters
    gnome-maps
    geary
    gnome-calendar
    simple-scan
  ];
}
