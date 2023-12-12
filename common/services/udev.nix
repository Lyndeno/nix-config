{
  lib,
  config,
}: {
  extraRules =
    lib.optionalString
    (builtins.elem "zfs" config.boot.supportedFilesystems) ''
      ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
    '';
}
