{
  pkgs,
  lib,
  isDesktop,
}: {
  enable = true;
  userName = "Lyndon Sanche";
  userEmail = "lsanche@lyndeno.ca";
  signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE90+2nMvJzOmkEGT3cyqHMESrrPQwVhe9/ToSlteJbB";
  # Signing key is not configured on headless environments
  signing.signByDefault = isDesktop;
  extraConfig = {
    pull.rebase = false;
    gpg.format = lib.mkIf isDesktop "ssh";
    "gpg \"ssh\"".program = lib.mkIf isDesktop "${pkgs._1password-gui}/share/1password/op-ssh-sign";
  };
  ignores = [
    "result"
    ".direnv/"
    ".envrc"
    ".vscode/"
  ];
}
