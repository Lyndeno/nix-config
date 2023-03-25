{
  pkgs,
  lib,
  isDesktop,
  ...
}: {
  programs.git = {
    enable = true;
    userName = "Lyndon Sanche";
    userEmail = "lsanche@lyndeno.ca";
    signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE90+2nMvJzOmkEGT3cyqHMESrrPQwVhe9/ToSlteJbB";
    # Signing key is not configured on headless environments
    signing.signByDefault = isDesktop;
    extraConfig = lib.mkMerge [
      {
        pull.rebase = false;
      }
      # We do not want 1password to be pulled in on headless environments
      (
        if isDesktop
        then {
          gpg.format = "ssh";
          "gpg \"ssh\"".program = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
        }
        else {}
      )
    ];
    ignores = [
      "result"
      ".direnv/"
      ".envrc"
      ".vscode/"
    ];
  };
}
