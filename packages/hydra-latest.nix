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
      # Resolve the latest successful Hydra build for a host to its store path.
      # Prints "<build-id> <store-path>" on stdout (store paths never contain
      # spaces, so callers can `read -r id path`).
      #
      #   hydra-latest [host] [system]
      #
      # host defaults to this machine, system to builtins.currentSystem.
      # Exit 2 on any error (query failed, build unsuccessful, no output path).

      HYDRA_URL="''${HYDRA_URL:-https://hydra.lyndeno.ca}"
      HYDRA_PROJECT="''${HYDRA_PROJECT:-nix-config}"
      HYDRA_JOBSET="''${HYDRA_JOBSET:-master}"

      HOST="''${1:-$(uname -n)}"
      SYSTEM="''${2:-$(nix eval --raw --impure --expr builtins.currentSystem)}"
      JOB="''${SYSTEM}.nixos-''${HOST}"

      BUILD="$(curl -sfL -H "Accept: application/json" \
        "''${HYDRA_URL}/job/''${HYDRA_PROJECT}/''${HYDRA_JOBSET}/''${JOB}/latest-finished")" || {
        echo "error: could not query Hydra for ''${JOB}" >&2
        exit 2
      }

      STATUS="$(jq -r '.buildstatus' <<<"$BUILD")"
      BUILD_ID="$(jq -r '.id' <<<"$BUILD")"
      if [ "$STATUS" != "0" ]; then
        echo "error: latest finished build #''${BUILD_ID} did not succeed (buildstatus=''${STATUS})" >&2
        exit 2
      fi

      STORE_PATH="$(jq -r '.buildoutputs.out.path' <<<"$BUILD")"
      if [ -z "$STORE_PATH" ] || [ "$STORE_PATH" = "null" ]; then
        echo "error: could not determine store path from build #''${BUILD_ID}" >&2
        exit 2
      fi

      printf '%s %s\n' "$BUILD_ID" "$STORE_PATH"
    '';

    meta.description = "Resolves the latest successful Hydra build for a host to its store path";
    meta.platforms = lib.platforms.linux;
  }
