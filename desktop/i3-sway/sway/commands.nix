{
  config,
  pkgs,
  ...
}: {
  lock = "${pkgs.swaylock}/bin/swaylock -f";
  terminal = "${pkgs.alacritty}/bin/alacritty";
  menu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu=\"${pkgs.bemenu}/bin/bemenu -i ${config.home-manager.users.lsanche.home.sessionVariables.BEMENU_OPTS} -c -H 25 -W 0.3\"";
}
