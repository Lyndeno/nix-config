{config}: {
  firewall = {
    interfaces = {
      "${config.services.tailscale.interfaceName}" = {
        allowedTCPPorts = config.services.openssh.ports;
      };
    };
  };
}
