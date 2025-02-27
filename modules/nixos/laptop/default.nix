{pkgs, ...}: {
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=2h
  '';

  services = {
    logind.lidSwitch = "suspend-then-hibernate";
  };

  environment.systemPackages = with pkgs; [
    gnome-network-displays
  ];
}
