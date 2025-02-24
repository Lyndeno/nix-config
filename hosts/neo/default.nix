{
  lib,
  pkgs,
}: {
  users.users.lsanche.createHome = true;
  programs.dconf.enable = true;

  security.tpm2.enable = true;

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=2h
  '';

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  networking = {
    networkmanager = {
      enable = true;
      settings.connectivity = {
        uri = "http://google.com/generate_204";
        response = "";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    sbctl
    gnome-network-displays
  ];
}
