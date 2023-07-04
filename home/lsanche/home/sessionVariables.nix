{
  pkgs,
  lib,
  isDesktop,
}:
lib.mkMerge [
  {
    # TODO: For some reason bat cannot theme man pages with custom themes, so we unset here
    MANPAGER = "sh -c '${pkgs.util-linux}/bin/col -bx | BAT_THEME= ${pkgs.bat}/bin/bat -l man -p'";
  }
  (lib.mkIf isDesktop {
    BROWSER = "firefox";
  })
]
