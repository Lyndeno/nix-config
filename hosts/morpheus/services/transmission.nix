{
  enable = true;
  settings = {
    rpc-bind-address = "0.0.0.0";
    rpc-whitelist = "100.*.*.*,192.168.15.5";
    download-dir = "/data/bigpool/media/torrents";
    incomplete-dir = "/data/bigpool/media/torrents/Incomplete";
  };
  group = "media";
}
