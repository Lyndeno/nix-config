{config, lib, pkgs, ...}:

with lib;

# This file defines the nebula mesh that all my Nix machines will use
# This it to cleanup the config and remove duplicate information whenever possible

let cfg = config.modules.services.nebula;
in {
  options.modules.services.nebula = {
    enable = mkEnableOption "Nebula";
    nodeName = with types; mkOption { type = nullOr (enum [ "oracle" "morpheus" "neo"]); default = null; };
    isLighthouse = with types; mkOption { type = bool; default = false; };
  };

  config = mkIf (cfg.enable && cfg.nodeName != null) {
    age.secrets = let
      getNebulaSecret = name: ../../hosts + "/${cfg.nodeName}" + /secrets/${name};
    in {
      nebula-ca-crt.file = getNebulaSecret "nebula.ca.crt.age";
      nebula-crt.file = getNebulaSecret "nebula.crt.age";
      nebula-key.file = getNebulaSecret "nebula.key.age";
    };

    services.nebula.networks = with config.age.secrets; {
      matrix = {
        key = nebula-key.path;
        cert = nebula-crt.path;
        ca = nebula-ca-crt.path;
        lighthouses = [ "10.10.10.1" ];
        isLighthouse = cfg.isLighthouse;
        staticHostMap = {
          "10.10.10.1" = [
            "cloud.lyndeno.ca:4242"
          ];
        };
        firewall = {
          inbound = [
            {
              host = "any";
              port = "any";
              proto = "any";
            }
          ];
          outbound = [
            {
              host = "any";
              port = "any";
              proto = "any";
            }
          ];
        };
      };
    };
  };
}