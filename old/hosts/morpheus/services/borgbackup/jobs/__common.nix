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
    config.services.postgresqlBackup.location
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
