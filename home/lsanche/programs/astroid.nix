{config}: {
  enable = true;
  pollScript = "${config.programs.mujmap.package}/bin/mujmap -C ~/Maildir/fastmail sync";
}
