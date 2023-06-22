{
  paths = [
    "/var/lib"
    "/srv"
    "/home"
    "/data/bigpool/archive"
  ];
  exclude = [
    "/var/lib/systemd"
    "/var/lib/libvirt"
    "/var/lib/plex"

    "**/target"
    "/home/*/.local/share/Steam"
    "/home/*/Downloads"
  ];
}
