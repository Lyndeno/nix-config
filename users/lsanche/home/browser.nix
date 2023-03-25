{
  pkgs,
  isDesktop,
  lib,
  inputs,
  ...
}: {
  # TODO: Add single variable to switch between Brave OR Firefox instead of having both
  home = lib.mkIf isDesktop {
    sessionVariables.BROWSER = "brave";
    file."firefox-gnome-theme" = {
      target = ".mozilla/firefox/lsanche/chrome/firefox-gnome-theme";
      source = inputs.firefox-gnome-theme;
    };
  };
  programs = lib.mkIf isDesktop {
    chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
        {id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";} # 1password
        {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # Sponsorblock
        {id = "bmnlcjabgnpnenekpadlanbbkooimhnj";} # Paypal Honey
      ];
    };

    firefox = {
      enable = true;
      profiles.lsanche = {
        id = 0;
        isDefault = true;
        userChrome = ''
          @import "firefox-gnome-theme/userChrome.css";
          @import "firefox-gnome-theme/theme/colors/dark.css";
        '';
        extraConfig = builtins.readFile "${inputs.firefox-gnome-theme}/configuration/user.js";
      };
    };
  };
}
