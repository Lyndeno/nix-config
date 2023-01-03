{ config,
  pkgs,
  lib,
  wallpaper,
  commands,
  homeCfg,
  thm,
  extraKeybindings ? {},
  extraStartup ? [], ...}:
let
  wobsock = "$XDG_RUNTIME_DIR/wob.sock";
in rec {
  inherit (commands) terminal menu;
  startup = extraStartup ++ [
      { command = "${pkgs.discord}/bin/discord --start-minimized"; }
      { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
      { command = "1password --silent"; }
      { command = if (config.modules.programs.gaming.enable && config.modules.programs.gaming.steam.enable) then "${config.programs.steam.package}/bin/steam -silent" else "echo Steam is not enabled"; }
      #{ command = with thm.withHashtag; "rm -f ${wobsock} && mkfifo ${wobsock} && tail -f ${wobsock} | ${pkgs.wob}/bin/wob --bar-color=${base07}ff --background-color=${base01}ff --border-color=${base07}ff -a bottom --margin 30"; }
  ];
  keybindings = lib.mkOptionDefault ({
      "${modifier}+l" = "exec ${commands.lock}";
      "${modifier}+grave" = "exec ${menu}";

      #TODO: Implement --locked
      "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -ui 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > ${wobsock}";
      "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -ud 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > ${wobsock}";
      "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer --toggle-mute && ( ${pkgs.pamixer}/bin/pamixer --get-mute && echo 0 > ${wobsock} ) || ${pkgs.pamixer}/bin/pamixer --get-volume > ${wobsock}";

      "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
      "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
      "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";

      #"print" = "exec --no-startup-id ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.wl-clipboard}/bin/wl-paste > ~/Pictures/$(date +'screenshot_%Y-%m-%d-%H%M%S.png')";
      "${modifier}+z" = "exec ${homeCfg.programs.alacritty.package}/bin/alacritty -e ${homeCfg.programs.nnn.package}/bin/nnn";

      "${modifier}+equal" = "gaps inner all plus 10";
      "${modifier}+minus" = "gaps inner all minus 10";
      "${modifier}+Shift+minus" = "gaps inner all set ${toString gaps.inner}";
  } // extraKeybindings);
  gaps = {
      inner = 20;
      smartGaps = true;
      smartBorders = "on";
  };
  window.titlebar = false;
  window.border = 3;
  modifier = "Mod4";
  workspaceAutoBackAndForth = true;
  #colors = with thm.withHashtag; {
  #  background = base07;
  #  focused = {
  #    border = base05;
  #    background = base0D;
  #    text = base00;
  #    indicator = base0D;
  #    childBorder = base0D;
  #  };
  #  focusedInactive = {
  #    border = base01;
  #    background = base01;
  #    text = base05;
  #    indicator = base03;
  #    childBorder = base01;
  #  };
  #  unfocused = {
  #    border = base01;
  #    background = base00;
  #    text = base05;
  #    indicator = base01;
  #    childBorder = base01;
  #  };
  #  urgent = {
  #    border = base08;
  #    background = base08;
  #    text = base00;
  #    indicator = base08;
  #    childBorder = base08;
  #  };
  #  placeholder = {
  #    border = base00;
  #    background = base00;
  #    text = base05;
  #    indicator = base00;
  #    childBorder = base00;
  #  };
  #};
}
