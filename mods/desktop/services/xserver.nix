{pkgs}: {
  desktopManager.plasma5 = {
    enable = true;
    runUsingSystemd = true;
  };
  displayManager = {
    sddm = {
      enable = true;
      settings = {
        General = {
          DisplayServer = "wayland";
          InputMethod = "";
        };
        Wayland.CompositorCommand = "${pkgs.weston}/bin/weston --shell=fullscreen-shell.so";
      };
    };
  };
  displayManager.defaultSession = "plasmawayland";
  enable = true;
}
