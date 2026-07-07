{
  osConfig,
  lib,
  pkgs,
  ...
}: {
  programs = {
    aerc = {
      enable = true;
      extraConfig = {
        general.unsafe-accounts-conf = true;
        filters = {
          "text/plain" = "colorize";
          "text/calendar" = "calendar";
          "message/delivery-status" = "colorize";
          "message/rfc822" = "colorize";
          "text/html" = "! html";
        };
        openers = {
          "x-scheme-handler/http*" = "qutebrowser --target window {}";
          "text/html" = "qutebrowser --target window {}";
        };
        ui = {
          index-columns = "flags:4,name<20%,labels<20%,subject,date>=";
          "column-labels" = "{{map .Labels (exclude .Folder) | join \" \"}}";
        };
        hooks = {
          "mail-received" = "${lib.getExe pkgs.libnotify} -a aerc \"New mail from $AERC_FROM_NAME\" \"$AERC_SUBJECT\"";
        };
        compose = {
          "file-picker-cmd" = "${lib.getExe pkgs.zenity} --file-selection --multiple --separator=$'\\n'";
        };
      };
      extraAccounts = {
        Fastmail = {
          source = "jmap+oauthbearer://api.fastmail.com/.well-known/jmap";
          source-cred-cmd = "cat ${osConfig.age.secrets.fastmail-jmap.path}";
          outgoing = "jmap://";
          default = "Inbox";
          from = "Lyndon Sanche <lsanche@lyndeno.ca>";
          aliases = "\"Lyndon Sanche\" <*@lyndeno.ca>";
          use-labels = true;
          cache-state = true;
          cache-blobs = true;
          folders-sort = "Inbox";
        };
      };
    };
  };

  xdg = {
    desktopEntries.aerc-mailto = {
      name = "aerc";
      exec = "${lib.getExe pkgs.alacritty} --class hover -e aerc %u";
      mimeType = ["x-scheme-handler/mailto"];
      type = "Application";
      noDisplay = true;
    };
    mimeApps.defaultApplications."x-scheme-handler/mailto" = "aerc-mailto.desktop";
  };
}
