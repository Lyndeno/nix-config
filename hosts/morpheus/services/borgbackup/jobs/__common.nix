{config}: {
  paths = [
    "/var/lib"
    "/srv"
    "/home"
    "/data/bigpool/archive"
    "/data/bigpool/immich/data/upload"
    "/data/bigpool/immich/data/library"
    config.services.paperless.dataDir
    "/var/lib/${config.services.calibre-web.dataDir}"
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
