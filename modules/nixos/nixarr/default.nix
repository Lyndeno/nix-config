{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nixarr.nixosModules.default
    inputs.agenix.nixosModules.default
  ];

  age.secrets.vpn.file = ../../../secrets/vpn.age;

  networking.firewall.allowedTCPPorts = [config.nixarr.transmission.peerPort];

  nixarr = {
    enable = true;
    mediaDir = "/data/bigpool/media/nixarr";
    stateDir = "/data/bigpool/media/nixarr/.state/nixarr";

    vpn = {
      enable = true;
      wgConf = config.age.secrets.vpn.path;
    };

    transmission = {
      enable = true;
      vpn.enable = true;
      peerPort = 27607;
      extraAllowedIps = ["100.*"];
      extraSettings = {
        idle-seeding-limit = "600";
        idle-seeding-limit-enabled = true;
        ratio-limit = "3.0";
        ratio-limit-enabled = true;
        download-queue-size = 50;
        seed-queue-size = 50;
        preallocation = 0;
        rpc-host-whitelist-enabled = true;
        rpc-host-whitelist = "transmission.${config.networking.domain}";
        peer-limit-global = 1000;
        peer-limit-per-torrent = 500;
      };
    };

    radarr.enable = true;
    sonarr.enable = true;
    prowlarr.enable = true;
  };

  services.localProxy.subDomains = let
    inherit (config.nixarr) radarr sonarr prowlarr transmission;
  in {
    radarr = {inherit (radarr) port;};
    sonarr = {inherit (sonarr) port;};
    prowlarr = {inherit (prowlarr) port;};
    transmission = {port = transmission.uiPort;};
  };
}
