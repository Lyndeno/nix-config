# meta.description = "Firefox browser with a declarative profile"
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    policies = {
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
        ];
      };
      settings = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        # Extensions installed from the Nix store count as sideloaded and are
        # disabled until approved unless no scopes are auto-disabled.
        "extensions.autoDisableScopes" = 0;
        # Tabs in the sidebar, like qutebrowser's tabs.position = "left", but
        # collapsed to icons until hovered.
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "expand-on-hover";
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
          }: {
            inherit name;
            urls = [{template = url;}];
            definedAliases = [keyword];
          }) {
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
      };
    };
  };

  stylix.targets.firefox = {
    profileNames = ["lsanche"];
    colorTheme.enable = true;
  };
}
