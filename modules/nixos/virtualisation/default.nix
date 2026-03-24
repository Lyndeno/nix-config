{
  pkgs,
  lib,
  ...
}: {
  programs.dconf.enable = lib.mkDefault true;
  environment.systemPackages = with pkgs; [
    virt-manager
  ];

  virtualisation = {
    libvirtd = {
      enable = true;

      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
  };
}
