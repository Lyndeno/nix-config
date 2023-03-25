{
  config,
  pkgs,
  lib,
  isDesktop,
  desktopEnv,
  ...
}: {
  config = let
    #swaylock-config = pkgs.callPackage ./swaylock.nix { thm = config.lib.stylix.colors; };
    commands = {
      lock = "${pkgs.i3lock}/bin/i3lock";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu=\"${pkgs.bemenu}/bin/bemenu -i ${config.home.sessionVariables.BEMENU_OPTS} -c -H 25 -W 0.3\"";
    };
    isI3 = (desktopEnv == "i3") && isDesktop;
  in
    lib.mkIf isI3 {
      xsession.windowManager.i3 = {
        enable = true;
        config = import ./common.nix {
          inherit config commands pkgs lib;
          thm = config.lib.stylix.colors;
          homeCfg = config.home-manager.users.lsanche;
        };
      };
    };
}
