{config}: {
  enable = true;
  clientMaxBodySize = "10M";

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
  };
}
