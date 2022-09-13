{config, lib, pkgs, ...}:

with lib;

# This file defines the nebula mesh that all my Nix machines will use
# This it to cleanup the config and remove duplicate information whenever possible

let
  cfg = config.modules.services.nebula;
  hosts = {
    oracle = "10.10.10.1";
    morpheus = "10.10.10.2";
    neo = "10.10.10.3";
    trinity = "10.10.10.4";
  };
in {
  options.modules.services.nebula = {
    enable = mkEnableOption "Nebula";
    nodeName = with types; mkOption { type = nullOr (enum (lib.mapAttrsToList (name: value: name) hosts)); default = null; };
    isLighthouse = with types; mkOption { type = bool; default = false; };
  };

  config = mkIf (cfg.enable && cfg.nodeName != null) {
    age.secrets = let
      getNebulaSecret = name: ../../secrets + "/${cfg.nodeName}" + /${name};
    in {
      nebula-ca-crt.file = ../../secrets/nebula.ca.crt.age;
      nebula-crt.file = getNebulaSecret "nebula.crt.age";
      nebula-key.file = getNebulaSecret "nebula.key.age";
    };

    networking.hosts = lib.mapAttrs' (name: value:
      lib.nameValuePair (value) ([ "${name}.matrix" ]) ) hosts;
  
    services.nebula.networks = with config.age.secrets; {
      matrix = {
        key = nebula-key.path;
        cert = nebula-crt.path;
        ca = nebula-ca-crt.path;
        lighthouses = [ "10.10.10.1" ];
        isLighthouse = cfg.isLighthouse;
        staticHostMap = {
          "${hosts.oracle}" = [
            "cloud.lyndeno.ca:4242"
          ];
        };
        settings = {
          relay = if cfg.isLighthouse then {
            am_relay = true;
          } else {
            relays = [ hosts.oracle ];
            use_relays = true;
          };
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
