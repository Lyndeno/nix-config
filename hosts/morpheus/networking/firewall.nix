{config}: {
  interfaces = {
    tailscale0 = {
      allowedTCPPorts = [config.services.paperless.port 4918];
    };
  };
}
