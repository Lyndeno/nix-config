{
  config,
  lib,
  pubKeys,
}: let
  keys = pubKeys.brandt;
in {
  isNormalUser = true;
  description = "Brandt Sanche";
  extraGroups = [
    "wheel"
  ];
  openssh.authorizedKeys.keys = [
    (lib.mkIf (keys ? ${config.networking.hostName}) keys.${config.networking.hostName})
  ];
}
