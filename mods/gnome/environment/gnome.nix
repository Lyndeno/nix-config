{pkgs}: {
  excludePackages = with pkgs; [
    gnome-tour
    gnome-text-editor
    evince
    epiphany
    gnome-font-viewer
    totem
    gnome.gnome-music
    gnome.gnome-characters
    gnome.gnome-maps
  ];
}
