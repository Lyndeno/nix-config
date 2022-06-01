{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.desktop;
in
{
  options = {
      modules = {
          desktop = {
              enable = mkOption {type = types.bool; default = false; };
              supportDDC = mkOption {type = types.bool; default = false; };
          };
      };
  };

  config = mkIf cfg.enable {
    programs.gnupg.agent.pinentryFlavor = "gnome3";


    services = {
        pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
        };
        #gnome.gnome-keyring.enable = true;
        #gvfs.enable = true; # for nautilus
    };
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  #services.xserver.displayManager.defaultSession = "plasmawayland";
  services.xserver.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    gnome-music
    gedit
    epiphany
    gnome-characters
    #tali
    #iagno
    #hitori
    #atomix
  ]);


    security = {
        rtkit.enable = true; # Realtime pipewire
        pam.services.gdm.u2fAuth = false;
        pam.services.sddm.enableGnomeKeyring = true;
    };

    programs = {
    };
  programs._1password-gui = {
	enable = true;
	polkitPolicyOwners = [ "lsanche" ];
	gid = 5000;
};


    boot.kernelModules = lib.optional cfg.supportDDC "i2c_dev";
    #services.udev.extraRules = lib.optionalString cfg.supportDDC ''
    #    KERNEL=="i2c-[0-9]*", TAG+="uaccess"
    #'';

    xdg.portal = {
        enable = true;
        #gtkUsePortal = true;
    };

    fonts.fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];

    hardware.pulseaudio.enable = false; # use pipewire instead

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
        gnomeExtensions.appindicator
        gnome.gnome-tweaks
        pika-backup
        gnomeExtensions.dash-to-panel
        gnomeExtensions.dash-to-dock
        fractal
        spot
      ] ++ (with plasma5Packages; [
        #kmail
        #kmail-account-wizard
        #kmailtransport
        #kalendar
        #kaddressbook
        #accounts-qt
        #kdepim-runtime
        #kdepim-addons
        #ark
        #okular
        #filelight
        #partition-manager
        #plasma-browser-integration
      ]);
      services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  };
}
