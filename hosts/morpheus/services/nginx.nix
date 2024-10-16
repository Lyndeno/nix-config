{config}: {
  enable = true;
  clientMaxBodySize = "50000M";
  proxyTimeout = "600s";

  recommendedProxySettings = true;
  recommendedTlsSettings = true;

  virtualHosts = {
    "paperless.lyndeno.ca" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://localhost:${builtins.toString config.services.paperless.port}";

        proxyWebsockets = true;
        extraConfig = ''
          add_header Referrer-Policy "strict-origin-when-cross-origin";
        '';
      };
    };
    "immich.lyndeno.ca" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://localhost:${builtins.toString config.services.immich.port}";

        proxyWebsockets = true;
      };
    };
    "${config.services.firefly-iii.virtualHost}" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;
    };
  };
}
