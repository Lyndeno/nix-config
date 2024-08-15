{
  config,
  secretPaths,
}: {
  secrets = with secretPaths; {
    id_borgbase.file = id_borgbase;
    pass_borgbase.file = morpheus.pass_borgbase;

    id_trinity_borg.file = morpheus.id_trinity_borg;
    pass_trinity_borg.file = morpheus.pass_trinity_borg;
    webdav = {
      file = morpheus.webdav;
      owner = config.services.webdav-server-rs.user;
      inherit (config.services.webdav-server-rs) group;
    };
    firefly-id = {
      file = morpheus.firefly_id;
      owner = config.services.firefly-iii.user;
      inherit (config.services.firefly-iii) group;
    };
  };
}
