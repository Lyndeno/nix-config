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
      dix
      nix
      systemd
      hydra-latest
    ];

    text = ''
      # Pull the latest Hydra build for this host and activate it, without
      # evaluating anything locally (like `nh os switch`, but the closure is
      # fetched from Hydra instead of being built here).

      # switch-to-configuration action: switch | boot | test | dry-activate
      if [ "$#" -lt 1 ]; then
        echo "usage: ''${0##*/} <switch|boot|test|dry-activate>" >&2
        exit 1
      fi
      ACTION="$1"

      echo ":: Querying Hydra"
      INFO="$(hydra-latest)"
      read -r BUILD_ID STORE_PATH <<<"$INFO"

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

    meta.description = "Activates the latest Hydra-built system closure fetched from the cache";
    meta.platforms = lib.platforms.linux;
  }
