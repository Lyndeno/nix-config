{flakeLib}: {
  secrets.fastmail_pass.file = flakeLib.secretPaths.fastmail;
}
