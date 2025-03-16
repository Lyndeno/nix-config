{
  targets = {
    swaylock = {
      useImage = false;
      enable = false;
    };
    nixvim = {
      transparentBackground = {
        main = true;
        signColumn = true;
      };
    };
    kde.enable = false;
    gtk.enable = false;
    gnome.enable = false;
    firefox.profileNames = ["lsanche"];
    qt.enable = false;
    gnome-text-editor.enable = false;
    vscode.profileNames = ["default"];
  };
  opacity = {
    terminal = 0.95;
  };
}
