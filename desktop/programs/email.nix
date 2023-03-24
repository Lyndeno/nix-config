_: {
  #age.secrets.fastmail = {
  #  file = ../secrets/fastmail.age;
  #  mode = "770";
  #  owner = "lsanche";
  #  group = "lsanche";
  #};

  home-manager.users.lsanche = {
    programs.astroid = {
      enable = true;
    };
    services.imapnotify.enable = true;
    #programs.mbsync.enable = true;
    programs.msmtp.enable = true;
    programs.neomutt = {
      enable = true;
      sort = "reverse-date";
      sidebar.enable = true;
      vimKeys = true;
    };
    programs.lieer.enable = true;
    programs.notmuch.enable = true;

    accounts.email = {
      maildirBasePath = ".Maildir";
      accounts.gmail = {
        primary = true;

        userName = "lyndeno@gmail.com";
        address = "lyndeno@gmail.com";
        realName = "Lyndon Sanche";
        flavor = "gmail.com";

        lieer.enable = true;
        notmuch.enable = true;
        astroid.enable = true;
        astroid.sendMailCommand = "";
      };
      #accounts.fastmail = {
      #  #primary = true;
      #  userName = "lsanche@fastmail.com";
      #  address = "lsanche@fastmail.com";
      #  realName = "Lyndon Sanche";
      #  imap = {
      #    host = "imap.fastmail.com";
      #    #port = 993;
      #  };
      #  smtp = {
      #    host = "smtp.fastmail.com";
      #  };
      #  passwordCommand = "${pkgs.busybox}/bin/cat ${config.age.secrets.fastmail.path}";
      #  mbsync = {
      #    enable = true;
      #    create = "maildir";
      #  };
      #  neomutt.enable = true;
      #  maildir.path = "fastmail";
      #  imapnotify = {
      #    enable = true;
      #    boxes = [ "Inbox" ];
      #    onNotify = "${pkgs.isync}/bin/mbsync -Va && ${pkgs.libnotify}/bin/notify-send 'Fastmail' 'New mail arrived'";
      #  };
      #};
    };
  };
}
