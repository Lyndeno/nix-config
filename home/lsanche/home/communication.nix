{
  pkgs,
  lib,
  isDesktop,
  ...
}: {
  home.packages = with pkgs;
    lib.mkIf isDesktop [
      signal-desktop
      discord
      element-desktop
      giara
      fractal
    ];
}
