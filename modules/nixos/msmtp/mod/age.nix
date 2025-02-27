{flake}: {
  secrets.fastmail_pass.file = flake.lib.secretPaths.fastmail;
}
