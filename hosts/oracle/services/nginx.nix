{
  pkgs,
  inputs,
}: {
  enable = true;
  virtualHosts."cloud.lyndeno.ca" = {
    root = "${inputs.site.packages.${pkgs.system}.default}/";
  };
}
