{
  enable = true;
  settings = {
    rpc-bind-address = "0.0.0.0";
    rpc-whitelist = "100.*.*.*,192.168.15.5,192.168.1.*,127.0.0.1";
    download-dir = "/data/bigpool/media/torrents";
    incomplete-dir = "/data/bigpool/media/torrents/Incomplete";
    peer-port = 27607;
    port-forwarding-enabled = true;
    peer-limit-global = 2000;
    peer-limit-per-torrent = 500;
  };
  group = "media";
}
