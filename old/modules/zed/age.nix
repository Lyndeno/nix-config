{flakeLib}:
with flakeLib.secretPaths; {
  secrets.zed_pushover.file = zed_pushover;
  secrets.zed_user.file = zed_user;
}
