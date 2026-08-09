# meta.description = "Calibre-Web ebook library server"
{config, ...}: {
  services = {
    calibre-web = {
      enable = true;
      listen.port = 8083;
      options = {
        enableBookUploading = true;
        enableBookConversion = true;
        enableKepubify = true;
      };
    };

    localProxy.subDomains.books = {
      inherit (config.services.calibre-web.listen) port;
    };
  };
}
