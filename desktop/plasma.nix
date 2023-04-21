{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.ls.desktop;
in {
  config = mkIf ((cfg.environment == "plasma") && cfg.enable) {
    programs.gnupg.agent.pinentryFlavor = "qt";

    services.gnome.gnome-keyring.enable = true;

    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      displayManager.defaultSession = "plasmawayland";
      desktopManager.plasma5 = {
        enable = true;
        # this seems to fix autostart applications (discord) not having proper icons in taskbar
        runUsingSystemd = true;
      };
    };

    environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";

    security.pam.services = {
      sddm.u2fAuth = false;
      sddm.enableGnomeKeyring = true;
    };

    programs.kdeconnect.enable = true;

    environment.systemPackages = with pkgs;
      [
        (mkIf cfg.software.backup vorta)
      ]
      ++ (with plasma5Packages; [
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
        plasma-integration
        plasma-browser-integration
        kaccounts-integration
        kaccounts-providers
      ]);
  };
}
