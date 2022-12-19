{config, pkgs, lib, ...}:
{
  virtualisation = {
    libvirtd = {
      enable = true;

      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull ];
        };
        swtpm.enable = true;
      };
    };
  };

  programs.dconf.enable = lib.mkDefault true;
  environment.systemPackages = with pkgs; [ virt-manager ];

  boot.kernelParams = [ "iommu=pt" ];
}
