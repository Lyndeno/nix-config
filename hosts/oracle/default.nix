_lib: inputs: _mods: commonModules:
[
  ./configuration.nix
  ./hardware.nix
  ({pkgs, ...}: {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    services.nginx.enable = true;
    services.nginx.virtualHosts."cloud.lyndeno.ca" = {
      root = "${inputs.site.packages.${pkgs.system}.default}/";
    };
  })
]
++ commonModules
