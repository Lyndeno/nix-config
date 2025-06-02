{pkgs}: {
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
    fuzzel
    xwayland-satellite
  ];

  services.displayManager.gdm = {
    enable = true;
  };

  security.pam.services.swaylock.enable = true;
  services = {
    gvfs.enable = true;
    gnome = {
      glib-networking.enable = true;
      localsearch.enable = true;
    };
  };
}
