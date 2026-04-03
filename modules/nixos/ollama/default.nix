{
  config,
  pkgs,
  ...
}: {
  services = {
    ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      rocmOverrideGfx = "10.3.0";
      host = "0.0.0.0";
    };

    open-webui = {
      enable = true;
      port = 8082;
      host = "0.0.0.0";
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}";
        WEBUI_AUTH = "False";
      };
    };

    localProxy.subDomains = {
      ollama = {};
      ai = {
        inherit (config.services.open-webui) port;
        extraConfig.proxyWebsockets = true;
      };
    };
  };
}
