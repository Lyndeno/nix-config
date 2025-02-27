{
  pkgs,
  lib,
  ...
}: {
  programs.dconf.enable = lib.mkDefault true;
  environment.systemPackages = with pkgs; [virt-manager];
  virtualisation.libvirtd = {
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
}
