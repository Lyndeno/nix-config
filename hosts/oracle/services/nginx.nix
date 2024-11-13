{
  pkgs,
  inputs,
}: {
  enable = true;
  virtualHosts."beta.lyndeno.ca" = {
    enableACME = true;
    forceSSL = true;
    root = "${inputs.site.packages.${pkgs.system}.default}/";
  };
  virtualHosts."invoice.lyndeno.ca" = {
    enableACME = true;
    forceSSL = true;
  };
}
