# meta.description = "Firefox browser with a declarative profile"
{config, ...}: {
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    profiles.lsanche = {
      id = 0;
      isDefault = true;
      extensions.force = true;
      settings = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };

  stylix.targets.firefox = {
    profileNames = ["lsanche"];
    colorTheme.enable = true;
  };
}
