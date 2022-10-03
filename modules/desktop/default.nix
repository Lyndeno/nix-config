{config, lib, pkgs, inputs, ...}:

with lib;

let
  cfg = config.modules.desktop;
  software = config.modules.desktop.software;
  defaults = {
    font = {
      package = (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" ]; });
      name = "CaskaydiaCove Nerd Font";
    };
  };

  environments = {
    gnome = {
      wayland = true;
    };
    plasma = {
      wayland = true;
    };
    sway = {
      wayland = true;
    };
    i3 = {
      wayland = true;
    };
  };
in
{
  imports = [
    ./gnome.nix
    ./plasma.nix
    ./hardware.nix
    (import ./i3-sway { inherit config lib pkgs defaults inputs; })
    ../../programs/desktop
  ];
  options = {
    modules = {
      desktop = {
        enable = mkOption {type = types.bool; default = false; };
        supportDDC = mkOption {type = types.bool; default = false; };
        software = {
          backup = mkOption {type = types.bool; default = true; };
        };
        environment = mkOption { type = types.nullOr (types.enum (lib.mapAttrsToList (name: value: name) environments)); default = null; };
        mainResolution = {
          width = mkOption { type = types.int; default = 1920; };
          height = mkOption { type = types.int; default = 1080; };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    hardware.pulseaudio.enable = false; # use pipewire instead
    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };

    security = {
      rtkit.enable = true; # Realtime pipewire
      pam.services = {
        login.u2fAuth = false;
      };
    };

    programs = {
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "lsanche" ];
      };
    };

    boot.kernelModules = lib.optional cfg.supportDDC "i2c_dev";
    #services.udev.extraRules = lib.optionalString cfg.supportDDC ''
    #    KERNEL=="i2c-[0-9]*", TAG+="uaccess"
    #'';

    xdg.portal = {
      enable = (cfg.environment != null);
    };

    fonts.fonts = with pkgs; [
      defaults.font.package
    ];

    environment.systemPackages = with pkgs; [
      alacritty
      #(lib.mkIf cfg.supportDDC ddcutil)
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = if environments.${cfg.environment}.wayland then "1" else "";

    stylix.targets = {
      gnome.enable = false;
      gtk.enable = false;
    };

    age.secrets.fastmail = {
      file = ../../secrets/fastmail.age;
      mode = "770";
      owner = "lsanche";
      group = "lsanche";
    };

    home-manager.users.lsanche = {

      ### EMAIL ###
      services.imapnotify.enable = true;
      programs.mbsync.enable = true;
      programs.msmtp.enable = true;
      programs.neomutt = {
        enable = true;
        sort = "reverse-date";
        sidebar.enable = true;
        vimKeys = true;
      };

      accounts.email = {
        maildirBasePath = ".Maildir";
        accounts.fastmail = {
          primary = true;
          userName = "lsanche@fastmail.com";
          address = "lsanche@fastmail.com";
          realName = "Lyndon Sanche";
          imap = {
            host = "imap.fastmail.com";
            #port = 993;
          };
          smtp = {
            host = "smtp.fastmail.com";
          };
          passwordCommand = "${pkgs.busybox}/bin/cat ${config.age.secrets.fastmail.path}";
          mbsync = {
            enable = true;
            create = "maildir";
          };
          neomutt.enable = true;
          maildir.path = "fastmail";
          imapnotify = {
            enable = true;
            boxes = [ "Inbox" ];
            onNotify = "${pkgs.isync}/bin/mbsync -Va && ${pkgs.libnotify}/bin/notify-send 'Fastmail' 'New mail arrived'";
          };
        };
      };

      home.packages = with pkgs; [
          defaults.font.package
          spotify
          zathura
          signal-desktop
          spotify
          discord
          libreoffice-qt
          imv
      ];

      programs.chromium = {
        enable = true;
        package = pkgs.brave;
        extensions = [
          { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1password
          { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # Sponsorblock
        ];
      };

      gtk = {
          enable = true;
          theme.name = "Adwaita-dark";
          theme.package = pkgs.gnome.gnome-themes-extra;
          iconTheme.name = "Papirus-Dark";
          iconTheme.package = pkgs.papirus-icon-theme;
      };

      programs.ssh.matchBlocks = {
        "* !*.repo.borgbase.com" = {
          extraOptions = {
            "IdentityAgent" = "~/.1password/agent.sock"; # 1password **should** exist if desktop is enabled
          };
        };
      };
    };
  };
}
