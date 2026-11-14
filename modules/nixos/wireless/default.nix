# meta.description = "Userspace Wireless Support"
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.captive-browser;

  # Firefox has no --proxy-server or --host-resolver-rules flags, so what
  # nixpkgs passes to Chromium is baked into this wrapper instead. Policies and
  # locked autoconfig prefs apply to every profile, including the throwaway
  # one below, and cannot be changed from inside the browser.
  firefox = pkgs.firefox.override {
    extraPolicies = {
      # All traffic through captive-browser's SOCKS5 proxy, with hostnames sent
      # to the proxy (remote DNS) so it resolves them against the DHCP DNS.
      Proxy = {
        Mode = "manual";
        SOCKSProxy = cfg.socks5-addr;
        SOCKSVersion = 5;
        UseProxyForDNS = true;
        Locked = true;
      };
      # DoH would bypass the proxy's resolver entirely.
      DNSOverHTTPS = {
        Enabled = false;
        Locked = true;
      };
      # The portal is being handled by hand; don't probe for it.
      CaptivePortal = false;
      # Stand-in for --no-first-run and -no-default-browser-check.
      DontCheckDefaultBrowser = true;
      OverrideFirstRunPage = "";
      NoDefaultBookmarks = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      # Remote Settings is left on, since it carries blocklists, but Nimbus
      # rollouts are not needed.
      DisableRemoteImprovements = true;
      # Built-in add-on updates (aus5.mozilla.org) are not needed either.
      DisableSystemAddonUpdate = true;
      # No Widevine download.
      EncryptedMediaExtensions = {
        Enabled = false;
        Locked = true;
      };

      # A throwaway profile gets Firefox's defaults, which phone home on
      # startup (ads, merino, Pocket images, suggestions). Keep it quiet so the
      # proxy log and the portal's DNS only see what the portal needs.
      NewTabPage = false;
      FirefoxHome = {
        Search = false;
        Weather = false;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Stories = false;
        SponsoredStories = false;
        SponsoredPocket = false;
        Pocket = false;
        Snippets = false;
        Widgets.Enabled = false;
      };
      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };
      SearchSuggestEnabled = false;
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        FirefoxLabs = false;
        WhatsNew = false;
      };
    };
    extraPrefs = ''
      // Never fall back to a direct connection (and a local lookup) if the
      // proxy is unreachable. Stands in for Chromium's
      // --host-resolver-rules="MAP * ~NOTFOUND" failing closed.
      lockPref("network.proxy.failover_direct", false);
      // No speculative lookups or connections that could resolve locally.
      lockPref("network.dns.disablePrefetch", true);
      lockPref("network.dns.disablePrefetchFromHTTPS", true);
      lockPref("network.dns.native_https_query", false);
      lockPref("network.prefetch-next", false);
      lockPref("network.predictor.enabled", false);
      lockPref("network.http.speculative-parallel-limit", 0);
      lockPref("network.connectivity-service.enabled", false);
      // WebRTC sends UDP straight out, around the proxy.
      lockPref("media.peerconnection.enabled", false);
      // The portal is usually a plain HTTP page; don't upgrade it.
      lockPref("dom.security.https_first", false);
      lockPref("dom.security.https_only_mode", false);
      // Background services that would otherwise look up their hosts.
      lockPref("browser.region.update.enabled", false);
      lockPref("browser.region.network.url", "");
      lockPref("geo.enabled", false);
      lockPref("dom.push.enabled", false);
      lockPref("app.normandy.enabled", false);
      lockPref("app.shield.optoutstudies.enabled", false);
      lockPref("messaging-system.rsexperimentloader.enabled", false);
      lockPref("browser.newtab.preload", false);
      lockPref("browser.discovery.enabled", false);
      lockPref("extensions.getAddons.cache.enabled", false);
      // A fresh profile downloads the OpenH264 and Widevine plugins about half
      // a minute after start. A portal page needs neither.
      lockPref("media.gmp-manager.updateEnabled", false);
      lockPref("media.gmp-manager.url", "");
      lockPref("media.gmp-provider.enabled", false);
      lockPref("media.gmp-gmpopenh264.enabled", false);
      lockPref("media.gmp-widevinecdm.enabled", false);
      // First-run pages and prompts.
      lockPref("browser.aboutwelcome.enabled", false);
      lockPref("browser.startup.homepage_override.mstone", "ignore");
      lockPref("datareporting.policy.dataSubmissionPolicyBypassNotification", true);
    '';
  };

  # Chromium gets a fixed profile directory in incognito mode. A fresh profile
  # that is deleted on exit gives the same no-state-across-runs behaviour, and
  # --no-remote keeps it from handing the URL to a running Firefox.
  captiveFirefox = pkgs.writeShellScript "captive-firefox" ''
    # captive-browser points XDG_CONFIG_HOME at a temporary directory holding
    # its own config; put the real one back for the browser.
    if [ -n "$PREV_CONFIG_HOME" ]; then
      export XDG_CONFIG_HOME="$PREV_CONFIG_HOME"
    else
      unset XDG_CONFIG_HOME
    fi

    profile=$(${pkgs.coreutils}/bin/mktemp -d)
    trap '${pkgs.coreutils}/bin/rm -rf "$profile"' EXIT

    ${lib.getExe firefox} --no-remote --profile "$profile" --new-window http://cache.nixos.org/
  '';
in {
  networking = {
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          AddressRandomization = "network";
        };
      };
    };
  };

  programs.captive-browser = {
    enable = true;
    interface = "wlan0";
    browser = "${captiveFirefox}";
    # The browser's proxy setting is fixed at build time, so pin the address
    # instead of leaving it as "localhost". An IP also avoids a lookup for it.
    socks5-addr = "127.0.0.1:1666";
  };
}
