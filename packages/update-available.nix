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
      curl
      jq
      nix
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
      #     "interval": 3600,
      #     "format": "{icon}",
      #     "format-icons": {"update-available": "󰚰", "up-to-date": "", "error": ""},
      #     "on-click": "update-system switch"
      #   }

      HYDRA_URL="''${HYDRA_URL:-https://hydra.lyndeno.ca}"
      HYDRA_PROJECT="''${HYDRA_PROJECT:-nix-config}"
      HYDRA_JOBSET="''${HYDRA_JOBSET:-master}"

      # Print waybar JSON: state, text, tooltip
      emit() {
        jq -cn --arg alt "$1" --arg text "$2" --arg tooltip "$3" \
          '{text: $text, alt: $alt, tooltip: $tooltip, class: $alt}'
      }

      HOST="$(uname -n)"
      SYSTEM="$(nix eval --raw --impure --expr builtins.currentSystem)"
      JOB="''${SYSTEM}.nixos-''${HOST}"

      BUILD="$(curl -sfL -H "Accept: application/json" \
        "''${HYDRA_URL}/job/''${HYDRA_PROJECT}/''${HYDRA_JOBSET}/''${JOB}/latest-finished")" || {
        emit error "" "Could not query Hydra for ''${JOB}"
        exit 0
      }

      STATUS="$(jq -r '.buildstatus' <<<"$BUILD")"
      BUILD_ID="$(jq -r '.id' <<<"$BUILD")"
      if [ "$STATUS" != "0" ]; then
        emit error "" "Latest finished build #''${BUILD_ID} did not succeed (buildstatus=''${STATUS})"
        exit 0
      fi

      LATEST="$(jq -r '.buildoutputs.out.path' <<<"$BUILD")"
      if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
        emit error "" "Could not determine store path from build #''${BUILD_ID}"
        exit 0
      fi

      CURRENT="$(readlink -f /run/current-system)"

      if [ "$CURRENT" = "$LATEST" ]; then
        emit up-to-date "" "System up to date (build #''${BUILD_ID})"
        exit 0
      fi

      emit update-available "1" \
        "$(printf 'Update available (build #%s)\ncurrent: %s\nlatest:  %s' \
          "$BUILD_ID" "$CURRENT" "$LATEST")"
    '';

    meta.platforms = lib.platforms.linux;
  }
