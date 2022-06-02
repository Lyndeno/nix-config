{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.modules.desktop;
in
{
  config = mkIf ((cfg.environment == "plasma") && cfg.enable) {
    programs.gnupg.agent.pinentryFlavor = "qt";

    services.gnome.gnome-keyring.enable = true;

    services.xserver = {
      displayManager.sddm.enable = true;
      displayManager.defaultSession = "plasmawayland";
      desktopManager.plasma5 = {
        enable = true;
        # this seems to fix autostart applications (discord) not having proper icons in taskbar
        runUsingSystemd = true;
        supportDDC = cfg.supportDDC;
      };
    };

    security.pam.services = {
      sddm.u2fAuth = false;
      sddm.enableGnomeKeyring = true;
    };

    xdg.portal.gtkUsePortal = true;

    programs.kdeconnect.enable = true;

    environment.systemPackages = with pkgs; [
      (mkIf cfg.software.backup vorta)
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
      plasma-browser-integration
    ]);
  };
}