{
  pkgs,
  lib,
  isDesktop,
  ...
}: {
  home.packages = with pkgs;
    lib.mkIf isDesktop [
      spotify
      spot
      fragments
      celluloid
    ];
}
