{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      notmuch
      systemd
    ];

    bashOptions = [];

    text = ''
      count="$(notmuch count tag:inbox and tag:unread)"

      refreshState="$(systemctl --user is-active refresh-email.service)"
      if [[ $refreshState == "active" ]]; then
        if [[ $count == "0" ]]; then
          echo 󰑐
        else
          echo "󰑐 $count"
        fi
      elif [[ $count == "0" ]]; then
        :
      else
        echo "󰇮 $count"
      fi
    '';

    meta.platforms = lib.platforms.linux;
  }
