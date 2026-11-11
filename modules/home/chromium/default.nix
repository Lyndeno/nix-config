# meta.description = "Chromium extensions and open-in-mpv integration"
{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    # Dark pages by default, like qutebrowser's colors.webpage.darkmode:
    # commandLineArgs = ["--enable-features=WebContentsForceDark"];
    extensions = [
      # Open in mpv (needs the open-in-mpv binary and mpv:// handler below)
      {
        id = "ggijpepdpiehgbiknmfpfbhcalffjlbj";
      }
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

  home.packages = [pkgs.open-in-mpv];

  # open-in-mpv's extension hands links to the mpv:// scheme handler
  xdg.mimeApps.defaultApplications."x-scheme-handler/mpv" = "open-in-mpv.desktop";
}
