{
  pkgs,
  lib,
  isDesktop,
}:
lib.mkMerge [
  {
    MANPAGER = "sh -c '${pkgs.util-linux}/bin/col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  }
  (lib.mkIf isDesktop {
    BROWSER = "firefox";
  })
]
