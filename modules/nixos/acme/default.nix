{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.lyndenoAcme;
in {
  options.services.lyndenoAcme = {
    enable = lib.mkEnableOption "ACME wildcard cert for this host's domain via acme-dns";

    email = lib.mkOption {
      type = lib.types.str;
      default = "lsanche@lyndeno.ca";
      description = "Contact email registered with Let's Encrypt.";
    };

    acmeDnsEndpoint = lib.mkOption {
      type = lib.types.str;
      default = "http://oracle:8080";
      description = "Base URL of the acme-dns server used for DNS-01 challenges.";
    };

    certGroup = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default =
        if config.services.nginx.enable
        then config.services.nginx.group
        else null;
      description = "Group to grant read access to the cert files (typically the reverse proxy's group).";
    };
  };

  config = lib.mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults = {
        inherit (cfg) email;
        dnsProvider = "acme-dns";
        environmentFile = pkgs.writeText "acme-env" ''
          ACME_DNS_API_BASE=${cfg.acmeDnsEndpoint}
          ACME_DNS_STORAGE_PATH=/var/lib/acme/.lego-acme-dns-accounts.json
        '';
      };
      certs."${config.networking.domain}" =
        {
          domain = "*.${config.networking.domain}";
        }
        // lib.optionalAttrs (cfg.certGroup != null) {
          group = cfg.certGroup;
        };
    };
  };
}
