{pkgs, ...}: {
  programs.niri.enable = true;
  environment.systemPackages = [pkgs.fuzzel];
}
