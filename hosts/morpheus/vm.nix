{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation = {
    libvirtd = {
      enable = true;

      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd];
        };
        swtpm.enable = true;
      };
    };
  };

  programs.dconf.enable = lib.mkDefault true;
  environment.systemPackages = with pkgs; [virt-manager];
  #environment.etc = {
  #  "ovmf/edk2-x86_64-secure-code.fd" = {
  #    source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
  #  };
  #};

  boot.kernelParams = ["iommu=pt"];
}
