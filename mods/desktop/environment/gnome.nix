{pkgs}: {
  excludePackages =
    (with pkgs; [
      gnome-tour
      gnome-text-editor
    ])
    ++ (with pkgs.gnome; [
      gnome-music
      gedit
      epiphany
      gnome-characters
      gnome-maps
      gnome-font-viewer
      totem
    ]);
}
