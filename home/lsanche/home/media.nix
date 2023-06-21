{pkgs, ...}: {
  home.packages = with pkgs; [
    spotify
    spot
    fragments
    celluloid
  ];
}
