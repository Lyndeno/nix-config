{
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
}
