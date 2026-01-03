{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];
  i18n.defaultLocale = "en_CA.UTF-8";
  boot.tmp.cleanOnBoot = true;
  environment.systemPackages = with pkgs; [
    #nh
    screen
    #perSystem.ironfetch.default
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
      keep-outputs = true;
      keep-derivations = true;
      always-allow-substitutes = true;
    };
    gc = {
      automatic = config.nix.enable;
      dates = "weekly";
      options = "--delete-older-than 60d";
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  };

  nixpkgs.config.allowUnfree = true;

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

  stylix = {
    enable = true;
    image = "${inputs.wallpapers}/sedona.jpg";
    overlays.enable = false;
    base16Scheme = "${inputs.base16-schemes}/base16/gruvbox-dark-hard.yaml";
    targets = {
      plymouth.enable = false;
      nixos-icons.enable = false;
      console.enable = false;
    };
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
    syncthing = {
      enable = true;
      user = "lsanche";
      dataDir = "/home/lsanche";
      configDir = "/home/lsanche/.config/syncthing";
      openDefaultPorts = true;
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
        (lib.mkIf config.programs.adb.enable "adbusers")
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
