{config}:
with config.age.secrets; {
  paths = [
    "/var/lib"
    "/srv"
    "/home"
  ];
  exclude = [
    "/var/lib/systemd"
    "/var/lib/libvirt"
    "/var/lib/plex"

    "**/target"
    "/home/*/.local/share/Steam"
    "/home/*/Downloads"
  ];
  repo = "f774k1bg@f774k1bg.repo.borgbase.com:repo";
  encryption = {
    mode = "repokey-blake2";
    passCommand = "cat ${pass_borgbase.path}";
  };
  environment.BORG_RSH = "ssh -i ${id_borgbase.path}";
  compression = "auto,zstd,10";
  startAt = "hourly";
  prune = {
    keep = {
      within = "3d";
      daily = 14;
      weekly = 4;
      monthly = -1;
    };
  };
}
