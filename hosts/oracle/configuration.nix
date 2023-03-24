# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
  networking.hostName = "oracle"; # Define your hostname.

  #boot.loader = {
  #  systemd-boot = {
  #    enable = true;
  #    consoleMode = "max";
  #  };
  #  timeout = 3;
  #  efi.canTouchEfiVariables = true;
  #};
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  networking.firewall = {
    extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp -i enp1s0 --dport 32400 -j DNAT --to-destination 100.127.0.11:32400
      iptables -I FORWARD -p tcp -d 100.127.0.11 --dport 32400 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
      iptables -I POSTROUTING -t nat -p tcp -d 100.127.0.11 --dport 32400 -j MASQUERADE

      iptables -t nat -A PREROUTING -p tcp -i enp1s0 --dport 25565 -j DNAT --to-destination 100.127.0.11:25565
      iptables -I FORWARD -p tcp -d 100.127.0.11 --dport 25565 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
      iptables -I POSTROUTING -t nat -p tcp -d 100.127.0.11 --dport 25565 -j MASQUERADE
    '';
    extraStopCommands = ''
      iptables -t nat -D PREROUTING -p tcp --dport 32400 -j DNAT --to-destination 100.127.0.11:32400 || true
      iptables -D FORWARD -p tcp -d 100.127.0.11 --dport 32400 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
      iptables -D POSTROUTING -t nat -p tcp -d 100.127.0.11 --dport 32400 -j MASQUERADE

      iptables -t nat -D PREROUTING -p tcp --dport 25565 -j DNAT --to-destination 100.127.0.11:25565 || true
      iptables -D FORWARD -p tcp -d 100.127.0.11 --dport 25565 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
      iptables -D POSTROUTING -t nat -p tcp -d 100.127.0.11 --dport 25565 -j MASQUERADE
    '';
  };

  networking.interfaces.enp1s0.ipv6.addresses = [
    {
      address = "2001:19f0:8001:b22:5400:03ff:feb9:980c";
      prefixLength = 64;
    }
  ];

  users.users.brandt = {
    isNormalUser = true;
    description = "Brandt Sanche";
    home = "/home/brandt";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAG5jQz86ZdWkHAl4795TUyYavrMKue/eOIglwvaGNGD"
    ];
  };

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  modules = {
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.interfaces.wlp2s0.useDHCP = true;
  networking.interfaces.enp1s0.useDHCP = true;

  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  system.autoUpgrade = {
    enable = true;
    flake = "github:Lyndeno/nix-config/master";
    allowReboot = true;
    dates = "03:00";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
