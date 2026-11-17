{
  pkgs,
  pname,
  inputs,
}: let
  inherit (pkgs) lib;
  pog = (inputs.pog.overlays.default pkgs pkgs).pog.pog;

  meta.description = "Activates the latest Hydra-built system closure fetched from the cache";
  meta.platforms = lib.platforms.linux;
in
  (pog {
    name = pname;
    description = "Activates the latest Hydra-built system closure fetched from the cache";
    version = "1.0.0";

    # Like `nh os switch`, but the closure is fetched from Hydra instead of
    # being built here. ACTION is a switch-to-configuration action:
    # switch | boot | test | dry-activate
    arguments = ["action"];

    flags = [
      {
        name = "yes";
        short = "y";
        bool = true;
        description = "skip the confirmation prompt";
      }
    ];

    runtimeInputs = with pkgs; [
      coreutils
      dix
      nix
      systemd
      hydra-latest
    ];

    script = helpers:
      with helpers; ''
        if [ "$#" -lt 1 ]; then
          die "usage: ${pname} [--yes] <switch|boot|test|dry-activate>" 1
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

        if ! ${flag "yes"}; then
          ${confirm {
          prompt = "Switch to this configuration ($ACTION)?";
          exit_code = 1;
        }}
        fi

        # Register the generation in the system profile before activating, so
        # rollbacks and boot entries track it (matches nixos-rebuild behaviour).
        if [ "$ACTION" = "switch" ] || [ "$ACTION" = "boot" ]; then
          run0 nix-env -p /nix/var/nix/profiles/system --set "$STORE_PATH"
        fi

        run0 "''${STORE_PATH}/bin/switch-to-configuration" "$ACTION"
      '';
  })
  .overrideAttrs (old: {meta = old.meta // meta;})
