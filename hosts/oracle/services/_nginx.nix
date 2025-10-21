{
  enable = true;
  virtualHosts."invoice.lyndeno.ca" = {
    enableACME = true;
    forceSSL = true;
  };
}
