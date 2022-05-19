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
    #nixpkgs.overlays = [
    #  (self: super: {
    #    plasma5Packages = super.plasma5Packages.overrideScope' ( pself: psuper: {

    #    kwallet = psuper.kwallet.overrideAttrs ( oldAttrs: {
    #      patches = [ (super.fetchpatch {
    #          url = "https://invent.kde.org/frameworks/kwallet/-/merge_requests/11.patch";
    #          sha256 = "sha256-kGWuhOPH+QddsiRaDCfzKgEf++gOYbQHUFBHEzDZXHE=";
    #        }
    #        )
    #      ];
    #    });
    #  });
    #})
    #];


    services = {
        pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
        };
        gnome.gnome-keyring.enable = true;
        #gvfs.enable = true; # for nautilus
    };
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
  services.xserver.desktopManager.plasma5.enable = true;


    security = {
        rtkit.enable = true; # Realtime pipewire
        pam.services.sddm.u2fAuth = false;
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
    services.udev.extraRules = lib.optionalString cfg.supportDDC ''
        KERNEL=="i2c-[0-9]*", TAG+="uaccess"
    '';

    xdg.portal = {
        enable = true;
        gtkUsePortal = true;
    };

    fonts.fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];

    hardware.pulseaudio.enable = false; # use pipewire instead

    environment.systemPackages = with pkgs; [
        firefox-wayland
        pavucontrol
        #(symlinkJoin {
        #    name = "vscode";
        #    paths = [ vscode ];
        #    buildInputs = [ makeWrapper ];
        #    postBuild = ''
        #        wrapProgram $out/bin/code \
        #        --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
        #    '';
        #})
        alacritty
        gnome.nautilus
        libnotify
        capitaine-cursors
        (lib.mkIf cfg.supportDDC ddcutil)
        brightnessctl
        pulseaudio # for pactl
        xdg-utils
      ] ++ (with plasma5Packages; [
        kmail
        kmail-account-wizard
        kmailtransport
        kalendar
        kaddressbook
        accounts-qt
        kdepim-runtime
        kdepim-addons
        ark
        okular
        filelight
        partition-manager
        brave
        plasma-browser-integration
        vscode
      ]);
  };
}
