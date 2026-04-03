{config, ...}: {
  services = {
    paperless = {
      enable = true;
      database.createLocally = true;
      settings = {
        PAPERLESS_URL = "https://paperless.${config.networking.domain}";
        PAPERLESS_CONSUMER_ENABLE_COLLATE_DOUBLE_SIDED = true;
        PAPERLESS_CONSUMER_RECURSIVE = true;
        PAPERLESS_CONSUMER_ENABLE_BARCODES = true;
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://localhost:${toString config.services.gotenberg.port}";
      };
      consumptionDirIsPublic = true;
      configureTika = true;
    };

    gotenberg.port = 3005;

    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          security = "user";
        };
        paperless = {
          path = config.services.paperless.consumptionDir;
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "paperless";
          "force group" = "paperless";
        };
      };
    };

    localProxy.subDomains.paperless = {
      extraConfig = {
        proxyWebsockets = true;
        extraConfig = ''
          add_header Referrer-Policy "strict-origin-when-cross-origin";
        '';
      };
    };
  };
}
