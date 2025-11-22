{
  enable = true;
  openFirewall = true;
  port = 8082;
  host = "0.0.0.0";
  environment = {
    OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
    # Disable authentication
    WEBUI_AUTH = "False";
  };
}
