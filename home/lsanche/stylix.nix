{isGnome}: {
  targets = {
    swaylock.useImage = false;
    kde.enable = false;
    gtk.enable = isGnome;
    firefox.profileNames = ["lsanche"];
  };
  opacity = {
    terminal = 0.95;
  };
}
