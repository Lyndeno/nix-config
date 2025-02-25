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
    "cache.lyndeno.ca" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      locations."/".extraConfig = ''
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
    "hydra.lyndeno.ca" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      locations."/".extraConfig = ''
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
    "${config.services.firefly-iii.virtualHost}" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;
    };
  };
}
