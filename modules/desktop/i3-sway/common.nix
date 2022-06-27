{ pkgs,
  lib,
  wallpaper,
  commands,
  homeCfg,
  thm, ...}:
let
  wobsock = "$XDG_RUNTIME_DIR/wob.sock";
in rec {
  startup = [
      { command = "dbus-update-activation-environment WAYLAND_DISPLAY"; }
      { command = "${pkgs.discord}/bin/discord --start-minimized"; }
      { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
      { command = "1password --silent"; }
      { command = with thm.withHashtag; "rm -f ${wobsock} && mkfifo ${wobsock} && tail -f ${wobsock} | ${pkgs.wob}/bin/wob --bar-color=${base07}ff --background-color=${base01}ff --border-color=${base07}ff -a bottom --margin 30"; }
  ];
  output."*" = { bg = "${wallpaper} fill"; };
  keybindings = lib.mkOptionDefault {
      "${modifier}+l" = "exec ${commands.lock}";
      "${modifier}+grave" = "exec ${menu}";

      #TODO: Implement --locked
      "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -ui 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > ${wobsock}";
      "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -ud 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > ${wobsock}";
      "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer --toggle-mute && ( ${pkgs.pamixer}/bin/pamixer --get-mute && echo 0 > ${wobsock} ) || ${pkgs.pamixer}/bin/pamixer --get-volume > ${wobsock}";

      "print" = "exec --no-startup-id ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.wl-clipboard}/bin/wl-paste > ~/Pictures/$(date +'screenshot_%Y-%m-%d-%H%M%S.png')";

      "${modifier}+equal" = "gaps inner all plus 10";
      "${modifier}+minus" = "gaps inner all minus 10";
      "${modifier}+Shift+minus" = "gaps inner all set ${toString gaps.inner}";
      "${modifier}+z" = "exec ${homeCfg.programs.alacritty.package}/bin/alacritty -e ${homeCfg.programs.nnn.package}/bin/nnn";
  };
  menu = let
    themeArgs = with thm.withHashtag; builtins.concatStringsSep " " [
      # Inspired from https://git.sr.ht/~h4n1/base16-bemenu_opts
      "--tb '${base01}'"
      "--nb '${base01}'"
      "--fb '${base01}'"
      "--hb '${base03}'"
      "--sb '${base03}'"
      "--hf '${base0A}'"
      "--sf '${base0B}'"
      "--tf '${base05}'"
      "--ff '${base05}'"
      "--nf '${base05}'"
      "--scb '${base01}'"
      "--scf '${base03}'"
    ];
  in "${pkgs.bemenu}/bin/bemenu-run -b -H 25 ${themeArgs} --fn 'Caskaydia Cove Mono 12'";
  window.titlebar = false;
  window.commands = [
      {
      criteria = {
          title = "^Picture-in-Picture$";
          app_id = "firefox";
      };
      command = "floating enable, move position 877 450, sticky enable";
      }
      {
      criteria = {
          title = "Firefox — Sharing Indicator";
          app_id = "firefox";
      };
      command = "floating enable, move position 877 450";
      }
  ];
  window.border = 3;
  terminal = "alacritty";
  modifier = "Mod4";
  input = {
      "type:touchpad" = {
      tap = "enabled";
      natural_scroll = "enabled";
      scroll_factor = "0.2";
      };
  };
  gaps = {
      inner = 20;
      smartGaps = true;
      smartBorders = "on";
  };
  workspaceAutoBackAndForth = true;
  bars = [];
}