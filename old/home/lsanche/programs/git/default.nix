{pkgs}: {
  package = pkgs.gitFull;
  enable = true;
  signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE90+2nMvJzOmkEGT3cyqHMESrrPQwVhe9/ToSlteJbB";
  settings = {
    pull.rebase = false;
    gpg.format = "ssh";
    user = {
      name = "Lyndon Sanche";
      email = "lsanche@lyndeno.ca";
    };
  };
  ignores = [
    "result"
    ".direnv/"
    ".envrc"
    ".vscode/"
  ];
}
