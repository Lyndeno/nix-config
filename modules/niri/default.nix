{pkgs}: {
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
    fuzzel
    xwayland-satellite
  ];

  services.xserver.displayManager.gdm = {
    enable = true;
  };
}
