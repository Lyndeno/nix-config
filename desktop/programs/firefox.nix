{config, pkgs, lib, inputs}:
{
  home-manager.users.lsanche = {
    home.file."firefox-gnome-theme" = {
      target = ".mozilla/firefox/lsanche/chrome/firefox-gnome-theme";
      source = inputs.firefox-gnome-theme;
    };
    programs.firefox = {
      enable = true;
      profiles.lsanche = {
        id = 0;
        isDefault = true;
        userChrome = ''
          @import "firefox-gnome-theme/userChrome.css";
          @import "firefox-gnome-theme/theme/colors/dark.css";
        '';
        #settings = {
        #  "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        #  "browser.uidensity" = 0;
        #  "svg.context-properties.content.enabled" = true;
        #  "browser.theme.dark-private-windows" = false;
        #};
        extraConfig = builtins.readFile "${inputs.firefox-gnome-theme}/configuration/user.js";
      };
    };
  };
}
