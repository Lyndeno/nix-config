# meta.description = "Firefox browser with a declarative profile"
{
  config,
  pkgs,
  ...
}: {
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    profiles.lsanche = {
      id = 0;
      isDefault = true;
      extensions = {
        force = true;
        packages = with pkgs.firefox-addons; [
          ublock-origin
          onepassword-password-manager
        ];
      };
      settings = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        # Extensions installed from the Nix store count as sideloaded and are
        # disabled until approved unless no scopes are auto-disabled.
        "extensions.autoDisableScopes" = 0;
      };
    };
  };

  stylix.targets.firefox = {
    profileNames = ["lsanche"];
    colorTheme.enable = true;
  };
}
