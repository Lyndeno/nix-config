# meta.description = "Experimental Clang ThinLTO variant of neo's trimmed kernel .config"
{pkgs, ...}: let
  # Kernel LTO needs a full LLVM toolchain (CC_IS_CLANG && LD_IS_LLD &&
  # AS_IS_LLVM) -- llvmPackages_<N>.stdenv alone isn't enough, it still
  # wraps GNU binutils for the linker/ar/nm by default (confirmed: its
  # cc.bintools.isLLVM is false). Building a cc that explicitly uses
  # llvmPackages_<N>.bintools is what actually gets LD_IS_LLD/AS_IS_LLVM.
  llvm = pkgs.llvmPackages_19;
  llvmCC = llvm.stdenv.cc.override {inherit (llvm) bintools;};
  llvmStdenv = pkgs.overrideCC llvm.stdenv llvmCC;

  # Same base kernel as neo-kernel-config.nix, but built with the LLVM
  # stdenv above so its `configfile` generation (which checks
  # stdenv.cc.isClang and asserts CC_IS_CLANG/LD_IS_LLD/AS_IS_LLVM) produces
  # a Clang-flavoured base config instead of a GCC one -- LTO_CLANG_THIN
  # isn't selectable at all against a GCC-generated config.
  kernel = pkgs.linuxPackages.kernel.override {stdenv = llvmStdenv;};
in
  kernel.configfile.overrideAttrs (old: {
    buildPhase =
      old.buildPhase
      + ''
        echo "trimming unloaded modules via localmodconfig"
        make $makeFlags -C . O="$buildRoot" ARCH=$kernelArch \
          LSMOD=${../hosts/neo/modprobed.db} localmodconfig

        echo "restoring USB storage and SD card support"
        ./scripts/config --file "$buildRoot/.config" \
          --module CONFIG_USB_STORAGE \
          --module CONFIG_MMC_BLOCK

        echo "enabling Clang ThinLTO"
        ./scripts/config --file "$buildRoot/.config" \
          --enable CONFIG_LTO_CLANG_THIN \
          --disable CONFIG_LTO_NONE

        make $makeFlags -C . O="$buildRoot" ARCH=$kernelArch olddefconfig
      '';
  })
