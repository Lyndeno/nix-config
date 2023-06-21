{pkgs}: {
  MANPAGER = "sh -c '${pkgs.util-linux}/bin/col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  BROWSER = "firefox";
}
