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
      dix
      nix
      systemd
    ];

    text = ''
      # Pull the latest Hydra build for this host and activate it, without
      # evaluating anything locally (like `nh os switch`, but the closure is
      # fetched from Hydra instead of being built here).

      HYDRA_URL="''${HYDRA_URL:-https://hydra.lyndeno.ca}"
      HYDRA_PROJECT="''${HYDRA_PROJECT:-nix-config}"
      HYDRA_JOBSET="''${HYDRA_JOBSET:-master}"

      # switch-to-configuration action: switch | boot | test | dry-activate
      if [ "$#" -lt 1 ]; then
        echo "usage: ''${0##*/} <switch|boot|test|dry-activate>" >&2
        exit 1
      fi
      ACTION="$1"

      HOST="$(uname -n)"
      SYSTEM="$(nix eval --raw --impure --expr builtins.currentSystem)"
      JOB="''${SYSTEM}.nixos-''${HOST}"

      echo ":: Querying Hydra for ''${HYDRA_PROJECT}:''${HYDRA_JOBSET}:''${JOB}"
      BUILD="$(curl -sfL -H "Accept: application/json" \
        "''${HYDRA_URL}/job/''${HYDRA_PROJECT}/''${HYDRA_JOBSET}/''${JOB}/latest-finished")"

      STATUS="$(jq -r '.buildstatus' <<<"$BUILD")"
      BUILD_ID="$(jq -r '.id' <<<"$BUILD")"
      if [ "$STATUS" != "0" ]; then
        echo "error: latest finished build #''${BUILD_ID} did not succeed (buildstatus=''${STATUS})" >&2
        exit 1
      fi

      STORE_PATH="$(jq -r '.buildoutputs.out.path' <<<"$BUILD")"
      if [ -z "$STORE_PATH" ] || [ "$STORE_PATH" = "null" ]; then
        echo "error: could not determine store path from build #''${BUILD_ID}" >&2
        exit 1
      fi

      echo ":: Build #''${BUILD_ID} -> ''${STORE_PATH}"

      echo ":: Realising closure"
      nix-store -r "$STORE_PATH" --log-format bar-with-logs

      echo ":: Changes"
      dix /run/current-system "$STORE_PATH" || true

      read -rp "Switch to this configuration (''${ACTION})? [Y/n] " reply
      case "''${reply:-y}" in
        [Yy]*) ;;
        *)
          echo "Aborted."
          exit 1
          ;;
      esac

      # Register the generation in the system profile before activating, so
      # rollbacks and boot entries track it (matches nixos-rebuild behaviour).
      if [ "$ACTION" = "switch" ] || [ "$ACTION" = "boot" ]; then
        run0 nix-env -p /nix/var/nix/profiles/system --set "$STORE_PATH"
      fi

      run0 "''${STORE_PATH}/bin/switch-to-configuration" "$ACTION"
    '';

    meta.platforms = lib.platforms.linux;
  }
