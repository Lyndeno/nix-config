{
  pkgs,
  lib,
}: {
  programs.dconf.enable = lib.mkDefault true;
  environment.systemPackages = with pkgs; [
    virt-manager
    docker-compose
  ];
}
