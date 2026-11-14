# meta.description = "Firefox browser with a declarative profile"
{
  config,
  lib,
  pkgs,
  ...
}: let
  nixosIcon = "https://search.nixos.org/images/nixos-logomark-default-gradient-none.svg";
in {
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    policies = {
      # Hand mpv:// links to the system handler (open-in-mpv) without asking.
      Handlers.schemes.mpv = {
        action = "useSystemDefault";
        ask = false;
      };

      # Telemetry and studies
      DisableTelemetry = true;
      DisableFirefoxStudies = true;

      # No Mozilla account sign-in or Sync
      DisableFirefoxAccounts = true;

      # 1Password handles logins and cards
      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;
      AutofillCreditCardEnabled = false;

      # The sidebar chatbot; other AI features are left alone
      AIControls.SidebarChatbot = {
        Value = "blocked";
        Locked = true;
      };

      # New tab page: just the search box and the weather
      FirefoxHome = {
        Search = true;
        Weather = true;
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
    };
    profiles.lsanche = {
      id = 0;
      isDefault = true;
      extensions = {
        force = true;
        packages = with pkgs.firefox-addons; [
          ublock-origin
          onepassword-password-manager
          # Open in mpv, the Firefox build of the open-in-mpv extension
          iina-open-in-mpv
        ];
      };
      settings = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        # Extensions installed from the Nix store count as sideloaded and are
        # disabled until approved unless no scopes are auto-disabled.
        "extensions.autoDisableScopes" = 0;
        # Always reopen the previous session, like qutebrowser's session.lazy_restore
        "browser.startup.page" = 3;
        # Tabs in the sidebar, like qutebrowser's tabs.position = "left", but
        # collapsed to icons until hovered.
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "expand-on-hover";
        # Sidebar launcher icons, without synced tabs or the AI chatbot.
        "sidebar.main.tools" = "opentabs,bookmarks,history,passwords";
        # Toolbar layout. Copied from a live profile, minus the "all tabs"
        # list button, with every extension under the extensions menu.
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            widget-overflow-fixed-list = [];
            unified-extensions-area = [
              "firefoxcolor_mozilla_com-browser-action"
              "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
              "ublock0_raymondhill_net-browser-action"
              "_d66c8515-1e0d-408f-82ee-2682f2362726_-browser-action"
            ];
            nav-bar = [
              "sidebar-button"
              "back-button"
              "forward-button"
              "stop-reload-button"
              "customizableui-special-spring1"
              "vertical-spacer"
              "urlbar-container"
              "customizableui-special-spring2"
              "downloads-button"
              "fxa-toolbar-menu-button"
              "reset-pbm-toolbar-button"
              "unified-extensions-button"
              "new-tab-button"
              "smartwindow-group-tabs-button"
              "ai-window-toggle"
            ];
            toolbar-menubar = ["menubar-items"];
            TabsToolbar = [];
            vertical-tabs = ["tabbrowser-tabs"];
            PersonalToolbar = ["import-button" "personal-bookmarks"];
          };
          seen = [
            "reset-pbm-toolbar-button"
            "smartwindow-group-tabs-button"
            "ai-window-toggle"
            "developer-button"
            "screenshot-button"
            "firefoxcolor_mozilla_com-browser-action"
            "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
            "ublock0_raymondhill_net-browser-action"
            "_d66c8515-1e0d-408f-82ee-2682f2362726_-browser-action"
          ];
          dirtyAreaCache = [
            "nav-bar"
            "TabsToolbar"
            "vertical-tabs"
            "PersonalToolbar"
            "toolbar-menubar"
            "unified-extensions-area"
          ];
          currentVersion = 28;
          newElementCount = 3;
        };
      };

      # Mirrors the qutebrowser and Chromium search engines; type the keyword
      # then a space in the address bar. DuckDuckGo is the default.
      search = {
        force = true;
        default = "ddg";
        engines =
          {
            # Built in, so it only takes the keyword.
            google.metaData.alias = "g";
          }
          // lib.mapAttrs (keyword: {
            name,
            url,
            icon,
          }: {
            inherit name;
            urls = [{template = url;}];
            iconMapObj."16" = icon;
            definedAliases = [keyword];
          }) {
            gh = {
              name = "GitHub";
              url = "https://github.com/search?q={searchTerms}";
              icon = "https://github.com/favicon.ico";
            };
            np = {
              name = "Nix Packages";
              url = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
              icon = nixosIcon;
            };
            no = {
              name = "NixOS Options";
              url = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
              icon = nixosIcon;
            };
            nd = {
              name = "NixOS Discourse";
              url = "https://discourse.nixos.org/search?q={searchTerms}";
              icon = "https://discourse.nixos.org/uploads/default/optimized/3X/a/5/a5e0d7873e3d34aecf874c577c91a1c06490f436_2_32x32.svg";
            };
            ng = {
              name = "Noogle";
              url = "https://noogle.dev/q/?term={searchTerms}";
              icon = "https://noogle.dev/favicon.ico";
            };
            cl = {
              name = "Claude";
              url = "https://claude.ai/new?q={searchTerms}";
              icon = "https://claude.ai/favicon.ico";
            };
            yt = {
              name = "YouTube";
              url = "https://www.youtube.com/results?search_query={searchTerms}";
              icon = "https://www.youtube.com/favicon.ico";
            };
          };
      };
    };
  };

  home.sessionVariables.BROWSER = "firefox";

  # The extension hands links to the mpv:// scheme, which this native helper
  # handles by starting mpv.
  home.packages = [pkgs.open-in-mpv];
  xdg.mimeApps.defaultApplications."x-scheme-handler/mpv" = "open-in-mpv.desktop";

  stylix.targets.firefox = {
    profileNames = ["lsanche"];
    colorTheme.enable = true;
  };
}
