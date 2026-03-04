{
  config,
  pkgs,
  osConfig,
  perSystem,
  lib,
  ...
}: let
  astroidPath = lib.getExe config.programs.astroid.package;

  updateScript = pkgs.writeShellScriptBin "update-email" ''
    echo "Display is $DISPLAY"
    echo "Wayland Display is $WAYLAND_DISPLAY"
    if [ "x$DISPLAY" != "x" ] || [ "w$WAYLAND_DISPLAY" != "w" ]; then
      echo "Telling Astroid we are polling"
      ${astroidPath} --start-polling 2>&1 >/dev/null
      astroidCode=$?
    fi

    ${config.programs.mujmap.package}/bin/mujmap -C ${config.home.homeDirectory}/Maildir/fastmail sync
    returnCode=$?

    if [ "x$DISPLAY" != "x" ] || [ "w$WAYLAND_DISPLAY" != "w" ]; then

      if [ $astroidCode != 0 ]; then
        echo "Astroid was not running previously, call refresh in case it has opened since then."
        ${astroidPath} --refresh 0 2>&1 >/dev/null
      else
        echo "Telling Astroid we are done polling"
        ${astroidPath} --stop-polling 2>&1 >/dev/null
      fi
    fi

    exit "$returnCode"
  '';
in {
  programs = {
    msmtp.enable = true;
    notmuch.enable = true;

    mujmap = {
      enable = true;
      package = perSystem.mujmap.default;
    };

    astroid = {
      enable = true;
      externalEditor = "${config.programs.alacritty.package}/bin/alacritty --class hover -e ${config.programs.nixvim.build.package}/bin/nvim -c 'set ft=mail' '+set fileencoding=utf-8' '+set ff=unix' '+set enc=utf-8' '+set fo+=w' %1";
      package = pkgs.astroid.overrideAttrs {
        patches = [
          (pkgs.fetchpatch {
            url = "https://github.com/astroidmail/astroid/commit/b84962a7920aaa9b0cc4a85a0c9fd1802495b1bc.patch";
            hash = "sha256-QO5hoWscSMcxWLjPn/NT2MaIKrgMvTJeutitm4GaKZY=";
          })
        ];
      };
    };
  };

  accounts = {
    email.accounts.fastmail = {
      primary = true;
      realName = "Lyndon Sanche";
      userName = "lsanche@fastmail.com";
      address = "lsanche@lyndeno.ca";
      msmtp.enable = true;
      smtp = {
        host = "smtp.fastmail.com";
        port = 465;
        tls.enable = true;
      };
      jmap = {
        sessionUrl = "https://api.fastmail.com/jmap/session";
      };
      notmuch = {
        enable = true;
      };
      mujmap = {
        enable = true;
        settings = {
          password_command = "cat ${osConfig.age.secrets.fastmail-jmap.path}";
        };
      };
      astroid = {
        enable = true;
        sendMailCommand = "${config.programs.mujmap.package}/bin/mujmap -C ${config.home.homeDirectory}/Maildir/fastmail send -i -t";
      };
    };
  };

  systemd = {
    user = {
      services = {
        refresh-email = {
          Unit = {
            Description = "Refresh Emails";
          };
          Service = {
            ExecStart = "${updateScript}/bin/update-email";
          };
        };
      };
      timers = {
        refresh-email = {
          Unit = {
            Description = "Refresh Emails";
          };
          Timer = {
            OnCalendar = "*:0/5";
          };
          Install = {
            WantedBy = ["timers.target"];
          };
        };
      };
    };
  };
}
