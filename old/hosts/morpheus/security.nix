{pkgs}: {
  acme = {
    acceptTerms = true;
    defaults = {
      email = "lsanche@lyndeno.ca";
      dnsProvider = "acme-dns";
      environmentFile = pkgs.writeText "acme-env" ''
        ACME_DNS_API_BASE=http://oracle:8080
        ACME_DNS_STORAGE_PATH=/var/lib/acme/.lego-acme-dns-accounts.json
      '';
    };
  };
}
