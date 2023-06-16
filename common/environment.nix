{pkgs}: {
  systemPackages = with pkgs; [
    vim
    git
    btrfs-progs
    busybox
    screen
  ];
}
