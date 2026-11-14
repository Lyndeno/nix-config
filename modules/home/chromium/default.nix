# meta.description = "Chromium extensions and open-in-mpv integration"
{
  programs.chromium = {
    enable = true;
    # Dark pages by default, like qutebrowser's colors.webpage.darkmode:
    # commandLineArgs = ["--enable-features=WebContentsForceDark"];
    extensions = [
      # 1Password
      {
        id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
      }
      # UBlock Origin Lite
      {
        id = "ddkjiahejlhfcafbddmgiahcphecmpfh";
      }
    ];
  };

  home.sessionVariables.BROWSER = "chromium";
}
