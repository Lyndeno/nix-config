{
  pkgs,
  inputs,
}: {
  systemPackages = with pkgs; [
    vim
    git
    btrfs-progs
    busybox
    screen
    inputs.cfetch.packages.${system}.default
    inputs.ironfetch.packages.${system}.default
  ];
}
