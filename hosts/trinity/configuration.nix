{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "trinity"; # Define your hostname.

  stylix.targets = {
    gnome.enable = false;
    gtk.enable = false;
  };

  services.borgbackup.repos = {
    neo = {
      path = "/data/borg/neo";
      authorizedKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/jyR1sMTHU3LoSweCtlAQwtaeUJGw/2LmOAKDuEXE3"];
    };
    morpheus = {
      path = "/data/borg/morpheus";
      authorizedKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP6nNQlJ+zzi+fmwDnXJ4eZXbp2JrS3fe2m04DlvstkO"];
    };
  };

  users.users.brandt = {
    isNormalUser = true;
    description = "Brandt Sanche";
    home = "/home/brandt";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAG5jQz86ZdWkHAl4795TUyYavrMKue/eOIglwvaGNGD"
    ];
    extraGroups = ["wheel"];
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:Lyndeno/nix-config/master";
    allowReboot = true;
    dates = "Mon, 03:30";
  };

  services.openssh = {
    enable = true;
    settings.permitRootLogin = "yes";
  };

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}
