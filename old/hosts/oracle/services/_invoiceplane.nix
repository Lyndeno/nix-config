{
  webserver = "nginx";
  sites."invoice.lyndeno.ca" = {
    enable = true;
    settings = {
      IP_URL = "https://invoice.lyndeno.ca";
    };
  };
}
