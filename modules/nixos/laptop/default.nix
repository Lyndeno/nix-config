{pkgs}: {
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=2h
  '';

  services = {
    logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  };

  environment.systemPackages = with pkgs; [
    gnome-network-displays
  ];
}
