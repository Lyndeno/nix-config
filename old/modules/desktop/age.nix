{flakeLib}: {
  secrets.fastmail-jmap = {
    file = flakeLib.secretPaths.fastmail_jmap;
    owner = "lsanche";
  };
}
