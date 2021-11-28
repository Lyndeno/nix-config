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
          };
      };
  };

  config = mkIf cfg.enable {
	services.xserver.enable = true;
	services.xserver.displayManager.gdm = {
		enable = true;
		wayland = true;
	};

    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    };

    programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
            swaylock
            swayidle
            wl-clipboard
            mako
            alacritty
			wofi
            waybar
            gammastep
        ];
        extraSessionCommands = ''
            eval $(gnome-keyring-daemon --start --daemonize)
            export SSH_AUTH_SOCK
        '';
    };

    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };

    fonts.fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];

	# verify this is where this should be
	services.gnome.gnome-keyring.enable = true;

    services.gvfs.enable = true; # for nautilus

    environment.systemPackages = with pkgs; [
        firefox-wayland
        spotify
        zathura
        pavucontrol
        signal-desktop
        vscode
        alacritty
        papirus-icon-theme
        gnome.nautilus
        gnome.seahorse
		libnotify
    ];
  };
}
