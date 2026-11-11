# meta.description = "Desktop base: Wayland session, PipeWire audio, printing, firmware updates, mDNS"
{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./audio.nix
    ./network.nix
    ./stylix.nix
  ];

  boot = {
    plymouth.enable = true;

    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];
  };
  documentation = {
    dev.enable = true;
    man.cache = {
      enable = true;
      generateAtRuntime = true;
    };
    #nixos.includeAllModules = true;
  };

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

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      #kdiskmark
      #rustdesk-flutter
      ppd
      man-pages
      nh
      ironfetch
      ncdu
      smartmontools
    ];
  };

  hardware = {
    keyboard.zsa.enable = true;
    # Unlikely to NOT need this on desktop
    enableRedistributableFirmware = true;
    bluetooth.enable = lib.mkDefault true;
  };
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  programs = {
    dconf.enable = true;
    fish = {
      enable = true;
      useBabelfish = true;
    };
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = ["lsanche"];
    };

    _1password = {
      enable = true;
    };

    #appimage = {
    #  enable = true;
    #};
  };
  security = {
    pam.services = {
      login.u2fAuth = false;
      gdm.u2fAuth = false;
    };
  };

  services = {
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
    resolved.enable = true;
    tailscale.useRoutingFeatures = lib.mkDefault "client";
    printing = {
      enable = true;
      #drivers = [ pkgs.epson-escpr2 ];
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  xdg.portal.enable = true;

  specialisation.troubleshoot = {
    configuration = {
      boot = {
        kernelParams = [
          "fsck.mode=force"
          "debug"
        ];

        plymouth.enable = lib.mkForce false;
        zfs.forceImportRoot = lib.mkForce true;
      };
      environment.etc."specialisation".text = "troubleshoot";
    };
  };
}
