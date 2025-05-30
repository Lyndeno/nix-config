{
  osConfig,
  config,
}: {
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
      sendMailCommand = "${config.programs.mujmap.package}/bin/mujmap -C /home/lsanche/Maildir/fastmail send -i -t";
    };
  };
}
