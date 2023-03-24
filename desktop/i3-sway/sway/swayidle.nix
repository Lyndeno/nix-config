{
  config,
  pkgs,
  lib,
  ...
}: let
  commands = import ./commands.nix {inherit config pkgs lib;};
in {
  home-manager.users.lsanche = {
    services.swayidle = let
      runInShell = name: cmd: "${pkgs.writeShellScript "${name}" ''${cmd}''}";
      pgrep = "${pkgs.procps}/bin/pgrep";
      cut = "${pkgs.coreutils-full}/bin/cut";
      systemctl = "${pkgs.systemd}/bin/systemctl";
      screenOn = runInShell "swayidle-screen-on" ''
        ${pkgs.sway}/bin/swaymsg "output * dpms on"
      '';
      lockScreenTimeout = runInShell "swayidle-lockscreen-timeout" ''
        if ${pgrep} swaylock
        then
          ${pkgs.sway}/bin/swaymsg "output * dpms off"
        fi
      '';
      screenTimeout = runInShell "swayidle-screen-off" ''
        ${pkgs.sway}/bin/swaymsg "output * dpms off"
      '';
      idleSleep = runInShell "swayidle-sleep-when-idle" ''
        BAT_STATUS=$(${pkgs.acpi}/bin/acpi -a | ${cut} -d" " -f3 | ${cut} -d- -f1)
        if [ "$BAT_STATUS" = "off" ]
        then
          ${systemctl} suspend-then-hibernate
        fi
      '';
      beforeSleep = runInShell "swayidle-before-sleep" ''
        ${pkgs.playerctl}/bin/playerctl pause
        if ! ${pgrep} swaylock
          then ${commands.lock}
        fi
      '';
    in {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = beforeSleep;
        }
      ];
      timeouts = [
        {
          timeout = 30;
          command = lockScreenTimeout;
          resumeCommand = screenOn;
        }
        {
          timeout = 180;
          command = "${commands.lock}";
        }
        {
          timeout = 200;
          command = screenTimeout;
          #resumeCommand = runInShell "swayidle-screen-on" ''
          #  swaymsg "output * dpms on"
          #'';
          resumeCommand = screenOn;
        }
        {
          timeout = 900;
          command = idleSleep;
        }
      ];
    };
  };
}
