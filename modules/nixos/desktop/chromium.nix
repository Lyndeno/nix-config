{lib, ...}: {
  programs.chromium = {
    enable = true;
    extraOpts = {
      # Telemetry and reporting
      MetricsReportingEnabled = false;
      SafeBrowsingExtendedReportingEnabled = false;
      UrlKeyedAnonymizedDataCollectionEnabled = false;
      FeedbackSurveysEnabled = false;
      UserFeedbackAllowed = false;

      # Privacy and security
      SafeBrowsingProtectionLevel = 1;
      BlockThirdPartyCookies = true;
      SyncDisabled = true;

      # UI and behavior
      TranslateEnabled = false;
      SpellCheckServiceEnabled = false;
      DefaultBrowserSettingEnabled = false;
      BackgroundModeEnabled = false;
      MediaRecommendationsEnabled = false;
      ShoppingListEnabled = false;
      # Hand PDFs to the default PDF app (zathura), like qutebrowser's download prompt
      AlwaysOpenPdfExternally = true;
      # Like qutebrowser's session.lazy_restore / auto_save.session
      RestoreOnStartup = 1;

      # Mirrors the qutebrowser search engines (modules/home/qutebrowser); type
      # the shortcut then a space in the address bar. DuckDuckGo is the default.
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderName = "DuckDuckGo";
      DefaultSearchProviderKeyword = "ddg";
      DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
      SiteSearchSettings =
        lib.mapAttrsToList (shortcut: {
          name,
          url,
        }: {
          inherit name shortcut url;
        }) {
          g = {
            name = "Google";
            url = "https://google.com/search?hl=en&q={searchTerms}";
          };
          gh = {
            name = "GitHub";
            url = "https://github.com/search?q={searchTerms}";
          };
          np = {
            name = "Nix Packages";
            url = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
          };
          no = {
            name = "NixOS Options";
            url = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
          };
          nd = {
            name = "NixOS Discourse";
            url = "https://discourse.nixos.org/search?q={searchTerms}";
          };
          ng = {
            name = "Noogle";
            url = "https://noogle.dev/q/?term={searchTerms}";
          };
          yt = {
            name = "YouTube";
            url = "https://www.youtube.com/results?search_query={searchTerms}";
          };
        };

      # Same sites qutebrowser allows notifications for
      NotificationsAllowedForUrls = [
        "https://outlook.cloud.microsoft"
        "https://teams.microsoft.com"
        "https://gitlab.com"
        "https://discourse.nixos.org"
      ];
    };
  };
}
