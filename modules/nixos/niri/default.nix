{pkgs, ...}: {
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
    fuzzel
    xwayland-satellite
    wdisplays
    bluetui
    wiremix
  ];

  security.soteria.enable = true;

  security.pam.services.swaylock.enable = true;
  services = {
    displayManager.gdm.enable = true;
    gnome.gcr-ssh-agent.enable = false;
    gvfs.enable = true;
    gnome = {
      glib-networking.enable = true;
      localsearch.enable = true;
    };
    upower.enable = true;
  };
}
