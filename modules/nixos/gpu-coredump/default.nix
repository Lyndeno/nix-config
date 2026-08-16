# meta.description = "Saves DRM/amdgpu device coredumps before the kernel expires them"
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.gpuCoredump;

  # The kernel drops a devcoredump into sysfs when a GPU hang is detected, then
  # deletes it roughly five minutes later. That window is far too short to catch
  # by hand, so a udev event kicks off this script the moment the node appears.
  captureScript = pkgs.writeShellScript "gpu-coredump-capture" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath [pkgs.coreutils pkgs.gzip pkgs.systemd]}:$PATH"

    dev="$1"
    src="${cfg.sourceDir}/$dev/data"
    dest="${cfg.outputDir}"
    base="$dest/$(date -u +%Y%m%dT%H%M%SZ)-$dev"

    if [ ! -r "$src" ]; then
      echo "no readable coredump at $src; it likely expired already" >&2
      exit 0
    fi

    # Dumps run to tens of megabytes uncompressed and compress very well.
    gzip -c "$src" > "$base.dump.gz"

    # The dump is written when the hang is detected, before the reset, so the
    # kernel ring buffer still holds the page faults that led up to it. Those
    # are what identify the faulting process, so keep them alongside the dump.
    journalctl -k -n 300 --no-pager > "$base.kmsg" 2>&1 || true

    chmod 0640 "$base.dump.gz" "$base.kmsg" || true
    echo "captured $(stat -c %s "$base.dump.gz") compressed bytes to $base.dump.gz"

    # Keep the newest ${toString cfg.maxDumps}; a reset loop must not fill the disk.
    ls -1t "$dest"/*.dump.gz 2>/dev/null | tail -n +$((${toString cfg.maxDumps} + 1)) | while read -r old; do
      rm -f "$old" "''${old%.dump.gz}.kmsg"
    done
  '';
in {
  options.services.gpuCoredump = {
    enable = lib.mkEnableOption "capture of DRM device coredumps to persistent storage";

    outputDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/gpu-coredumps";
      description = "Directory the captured dumps and their kernel log context are written to.";
    };

    maxDumps = lib.mkOption {
      type = lib.types.ints.positive;
      default = 20;
      description = ''
        Number of captures to retain. Older dumps are pruned after each capture
        so that a repeated hang cannot exhaust the filesystem.
      '';
    };

    sourceDir = lib.mkOption {
      type = lib.types.str;
      default = "/sys/class/devcoredump";
      description = ''
        Where devcoredump nodes appear. Only worth changing in tests, which
        point it at a fixture directory instead of real sysfs.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = ["d ${cfg.outputDir} 0750 root root -"];

    systemd.services."gpu-coredump-capture@" = {
      description = "Capture DRM device coredump %i";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${captureScript} %i";
      };
    };

    # Hand off to systemd rather than doing the copy in RUN+=, so a large dump
    # cannot stall the udev event queue.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="devcoredump", TAG+="systemd", ENV{SYSTEMD_WANTS}+="gpu-coredump-capture@%k.service"
    '';
  };
}
