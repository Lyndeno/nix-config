{
  enable = true;
  settings = {
    general = {
      nsname = "auth.lyndeno.ca";
      nsadmin = "system.lyndeno.ca";
      listen = ":53";
      domain = "auth.lyndeno.ca";
      records = [
        "auth.lyndeno.ca. A 45.63.35.22"
        "auth.lyndeno.ca. NS auth.lyndeno.ca."
      ];
    };
    api = {
      #tls = "letsencrypt";
      ip = "0.0.0.0";
      port = 8080;
      #acme_cache_dir = "api-certs";
      notification_email = "lsanche@lyndeno.ca";
    };
  };
}
