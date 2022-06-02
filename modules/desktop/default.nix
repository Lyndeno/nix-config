{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.desktop;
  software = config.modules.desktop.software;
in
{
  imports = [
    ./gnome.nix
  ];
  options = {
    modules = {
      desktop = {
        enable = mkOption {type = types.bool; default = false; };
        supportDDC = mkOption {type = types.bool; default = false; };
        software = {
          backup = mkOption {type = types.bool; default = true; };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.gnupg.agent.pinentryFlavor = "gnome3";

    hardware.pulseaudio.enable = false; # use pipewire instead
    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
    };

    environment.gnome.excludePackages = (with pkgs; [
      gnome-tour
    ]) ++ (with pkgs.gnome; [
      gnome-music
      gedit
      epiphany
      gnome-characters
    ]);

    security = {
      rtkit.enable = true; # Realtime pipewire
      pam.services = {
        gdm.u2fAuth = false;
        login.u2fAuth = false;
      };
    };

    programs = {
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "lsanche" ];
        gid = 5000;
      };
    };

    boot.kernelModules = lib.optional cfg.supportDDC "i2c_dev";
    #services.udev.extraRules = lib.optionalString cfg.supportDDC ''
    #    KERNEL=="i2c-[0-9]*", TAG+="uaccess"
    #'';

    xdg.portal = {
      enable = true;
    };

    fonts.fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];

    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    environment.systemPackages = with pkgs; [
      firefox-wayland
      pavucontrol
      alacritty
      libnotify
      #(lib.mkIf cfg.supportDDC ddcutil)
      brightnessctl
      xdg-utils
      ( pkgs. symlinkJoin {
          name = "vscode";
          pname = "vscode";
          paths = [ pkgs.vscode ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/code \
              --add-flags "--ozone-platform=wayland --enable-features=WaylandWindowDecorations"
          '';
      })
      brave
      gnome.gnome-tweaks
      ( mkIf software.backup pika-backup )
      fractal
      spot
    ] ++ (with gnomeExtensions; [
      appindicator
      dash-to-panel
      dash-to-dock
    ]);
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  };
}
