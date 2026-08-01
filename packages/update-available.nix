{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      coreutils
      jq
      hydra-latest
    ];

    text = ''
      # Check whether Hydra has a newer build for this host than what is
      # currently running, by comparing store paths. No local evaluation.
      #
      # Emits a single line of Waybar JSON on stdout and always exits 0 so the
      # module renders. The state is carried in `alt`/`class`:
      #   update-available | up-to-date | error
      #
      # Example waybar config:
      #   "custom/update": {
      #     "exec": "update-available",
      #     "return-type": "json",
      #     "interval": 300,
      #     "format": "{icon}",
      #     "format-icons": {"update-available": "󰚰", "up-to-date": "", "error": ""},
      #     "on-click": "update-system switch"
      #   }

      # Print waybar JSON: state, text, tooltip
      emit() {
        jq -cn --arg alt "$1" --arg text "$2" --arg tooltip "$3" \
          '{text: $text, alt: $alt, tooltip: $tooltip, class: $alt}'
      }

      if ! INFO="$(hydra-latest 2>/dev/null)"; then
        emit error "" "Could not resolve latest Hydra build for this host"
        exit 0
      fi
      read -r BUILD_ID LATEST <<<"$INFO"

      CURRENT="$(readlink -f /run/current-system)"

      if [ "$CURRENT" = "$LATEST" ]; then
        emit up-to-date "" "System up to date (build #''${BUILD_ID})"
        exit 0
      fi

      emit update-available "1" \
        "$(printf 'Update available (build #%s)\ncurrent: %s\nlatest:  %s' \
          "$BUILD_ID" "$CURRENT" "$LATEST")"
    '';

    meta.description = "Waybar module reporting whether a newer Hydra build is available";
    meta.platforms = lib.platforms.linux;
  }
