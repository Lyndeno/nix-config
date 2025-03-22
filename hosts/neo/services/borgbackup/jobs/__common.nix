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
    "**/.notmuch"
    "/home/*/.local"
    "/home/*/.cache"
    "/home/*/.mozilla"
    "/home/*/Downloads"
  ];
}
