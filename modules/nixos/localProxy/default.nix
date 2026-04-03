{
  config,
  lib,
  pkgs,
  ...
}: let
  mkVirtualHost = _: cfg: let
    serverName = "${cfg.subDomain}.${config.networking.domain}";
  in
    lib.nameValuePair serverName {
      inherit serverName;
      useACMEHost = config.networking.domain;
      acmeRoot = null;
      forceSSL = true;
      locations."/" =
        {
          proxyPass = lib.mkIf (cfg.port != null) "http://localhost:${toString cfg.port}";
        }
        // cfg.extraConfig;
    };
in {
  options = {
    services.localProxy = {
      enable = lib.mkEnableOption "proxy to local services";

      subDomains = lib.mkOption {
        description = ''
          Local services to attach to subdomains
        '';
        default = {};
        type = lib.types.attrsOf (
          lib.types.submodule (
            let
              globalConfig = config;
            in
              {name, ...}: {
                options = {
                  subDomain = lib.mkOption {
                    description = "Subdomain to use";
                    type = lib.types.str;
                    default = name;
                  };

                  port = lib.mkOption {
                    description = "Local port to proxy to";
                    type = lib.types.nullOr lib.types.port;
                    default = globalConfig.services.${name}.port;
                  };

                  extraConfig = lib.mkOption {
                    description = "Extra configuration to pass to nginx virtualhost";
                    type = lib.types.attrs;
                    default = {};
                  };
                };
              }
          )
        );
      };
    };
  };

  config = {
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "lsanche@lyndeno.ca";
        dnsProvider = "acme-dns";
        environmentFile = pkgs.writeText "acme-env" ''
          ACME_DNS_API_BASE=http://oracle:8080
          ACME_DNS_STORAGE_PATH=/var/lib/acme/.lego-acme-dns-accounts.json
        '';
      };
      certs."${config.networking.domain}" = {
        inherit (config.services.nginx) group;
        domain = "*.${config.networking.domain}";
      };
    };

    services.nginx = {
      enable = true;
      clientMaxBodySize = "50000M";
      proxyTimeout = "600s";

      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = lib.mkForce false;
      recommendedOptimisation = lib.mkForce false;

      virtualHosts = lib.mapAttrs' mkVirtualHost config.services.localProxy.subDomains;
    };
  };
}
