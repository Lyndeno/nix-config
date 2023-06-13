{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.vm;
in {
  options = {
    modules = {
      services = {
        vm = {
          enable = mkEnableOption "Common virtualisation settings";
        };
      };
    };
  };

  config = mkIf cfg.enable {
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
  };
}
