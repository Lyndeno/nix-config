{
  pkgs,
  pname,
  inputs,
}: let
  inherit (pkgs) lib;
  pog = (inputs.pog.overlays.default pkgs pkgs).pog.pog;

  meta.description = "Resolves the latest successful Hydra build for a host to its store path";
  meta.platforms = lib.platforms.linux;
in
  (pog {
    name = pname;
    description = "Resolves the latest successful Hydra build for a host to its store path";
    version = "1.0.0";

    # Prints "<build-id> <store-path>" on stdout (store paths never contain
    # spaces, so callers can `read -r id path`). Exit 2 on any error.
    arguments = ["host" "system"];

    flags = [
      {
        name = "url";
        description = "Hydra base URL";
        default = "https://hydra.lyndeno.ca";
        envVar = "HYDRA_URL";
      }
      {
        name = "project";
        description = "Hydra project";
        default = "nix-config";
        envVar = "HYDRA_PROJECT";
      }
      {
        name = "jobset";
        description = "Hydra jobset";
        default = "master";
        envVar = "HYDRA_JOBSET";
      }
    ];

    runtimeInputs = with pkgs; [
      coreutils
      curl
      jq
      nix
    ];

    script = ''
      HOST="''${1:-$(uname -n)}"
      SYSTEM="''${2:-$(nix eval --raw --impure --expr builtins.currentSystem)}"
      JOB="''${SYSTEM}.nixos-''${HOST}"

      BUILD="$(curl -sfL -H "Accept: application/json" \
        "''${url}/job/''${project}/''${jobset}/''${JOB}/latest-finished")" || {
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
  })
  .overrideAttrs (old: {meta = old.meta // meta;})
