# meta.description = "Trimmed kernel .config for neo, generated via localmodconfig"
{pkgs, ...}: let
  # Pinned to a concrete package, not linuxPackages_latest — it must stay the
  # same derivation that hosts/neo/configuration.nix overrides with the
  # committed kernel.config, or the two drift out of sync across nixpkgs
  # updates (new default kernel version, this still generated against the old one).
  kernel = pkgs.linuxPackages.kernel;
in
  kernel.configfile.overrideAttrs (old: {
    buildPhase =
      old.buildPhase
      + ''
        echo "trimming unloaded modules via localmodconfig"
        make $makeFlags -C . O="$buildRoot" ARCH=$kernelArch \
          LSMOD=${../hosts/neo/modprobed.db} localmodconfig

        # localmodconfig only knows what modprobed-db saw loaded: USB mass
        # storage and the SD-card block layer never got exercised during
        # recording (no USB stick / SD card was inserted), so it disabled
        # them entirely. NixOS's initrd wants both (usb_storage explicitly,
        # per modules/nixos/xps-9560/default.nix; mmc_block alongside the
        # rtsx_pci_sdmmc reader), and losing them system-wide (not just at
        # boot) is worse than the config being slightly less minimal.
        echo "restoring USB storage and SD card support"
        ./scripts/config --file "$buildRoot/.config" \
          --module CONFIG_USB_STORAGE \
          --module CONFIG_MMC_BLOCK
        make $makeFlags -C . O="$buildRoot" ARCH=$kernelArch olddefconfig
      '';
  })
