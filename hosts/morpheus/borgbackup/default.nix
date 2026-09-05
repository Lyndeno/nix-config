{config, ...}:
with config.age.secrets; {
  age.secrets = {
    id_borgbase.file = ../../../secrets/id_borgbase.age;
    pass_borgbase.file = ../../../secrets/morpheus/pass_borgbase.age;
  };

  services.hostBackup = {
    enable = true;
    repository = "n2ikk4w3@n2ikk4w3.repo.borgbase.com:repo";
    passCommand = "cat ${pass_borgbase.path}";
    sshKey = id_borgbase.path;
    startAt = "hourly";

    # /var/lib (from the module's common set) already covers paperless,
    # calibre-web, and the *arr configs, so only the off-/var/lib data
    # needs listing here.
    extraSourceDirectories = [
      "/data/bigpool/archive"
      "/data/bigpool/immich/data/upload"
      "/data/bigpool/immich/data/library"
    ];

    extraExcludes = [
      # Captured logically via the postgresql_databases hook below; the
      # on-disk data dir would only be a torn, unrestorable copy.
      "/var/lib/postgresql"
      # Re-downloadable LLM weights, gigabytes each.
      "/var/lib/llama-swap"
    ];

    # Dump the whole cluster via pg_dumpall (fail-safe: new databases are
    # picked up automatically, and cluster globals like roles/grants are
    # captured too), excluding atticd — ~7 GB of reproducible binary-cache
    # metadata whose NAR storage isn't backed up anyway. Leaving `format`
    # unset selects pg_dumpall and a plain, uncompressed stream, which borg
    # then dedups and compresses itself.
    postgresqlDatabases = [
      {
        name = "all";
        username = "postgres";
        options = "--exclude-database=atticd";
      }
    ];
  };
}
