{pkgs, ...}: {
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
    fuzzel
    xwayland-satellite
    wdisplays
  ];

  programs.regreet.enable = true;

  security.pam.services.swaylock.enable = true;
  services = {
    gvfs.enable = true;
    gnome = {
      glib-networking.enable = true;
      localsearch.enable = true;
    };
    upower.enable = true;
    greetd.enable = true;
  };

  stylix = {
    targets.regreet = {
      useWallpaper = false;
    };
  };
}
