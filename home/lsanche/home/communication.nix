{pkgs, ...}: {
  home.packages = with pkgs; [
    signal-desktop
    discord
    element-desktop
    giara
    fractal
  ];
}
