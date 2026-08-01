# meta.description = "Plex Media Server"
{
  services.plex = {
    enable = true;
    openFirewall = true;
    group = "media";
  };
}
