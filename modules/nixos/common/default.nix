{inputs, ...}: {
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  i18n.defaultLocale = "en_CA.UTF-8";
  boot = {
    tmp.cleanOnBoot = true;
    swraid.enable = false;
  };
  environment.systemPackages = with pkgs; [
    #nh
    screen
  ];
  networking = {
    useDHCP = false;
    firewall = {
      interfaces = {
        "${config.services.tailscale.interfaceName}" = {
          allowedTCPPorts = config.services.openssh.ports;
        };
      };
    };
  };

  nix = {
    optimise.automatic = config.nix.enable;
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      always-allow-substitutes = true;
    };
    gc = {
      automatic = config.nix.enable;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 60d";
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  };

  security = {
    sudo = {
      enable = false;
      execWheelOnly = true;
    };
    pam = {
      u2f = {
        enable = true;
        settings.cue = true;
      };
      #enableSSHAgentAuth = true;
    };
    polkit.enable = true;
  };

  systemd = {
    network.enable = true;
    settings.Manager = {
      DefaultTimeoutStopSec = "10s";
    };
  };

  services = {
    tailscale.enable = true;
    dbus.implementation = "broker";
    openssh = {
      enable = true;
      startWhenNeeded = true;
      settings = {
        # Disable password authentication
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
      openFirewall = false;
    };
  };

  users = let
    keys = (import ../../../pubKeys.nix).lsanche;
  in {
    groups.media = {};
    users.lsanche = {
      isNormalUser = true;
      description = "Lyndon Sanche";
      uid = 1000;
      initialPassword = "test";
      extraGroups = [
        "wheel"
        "media"
        (lib.mkIf config.programs.wireshark.enable "wireshark")
        "libvirtd"
        "dialout"
        "plugdev"
        "uaccess"
      ];
      shell = lib.mkIf config.programs.fish.enable config.programs.fish.package;
      openssh.authorizedKeys.keys = [
        (lib.mkIf (keys ? ${config.networking.hostName}) keys.${config.networking.hostName})
      ];
    };
  };
}
