{
  pkgs,
  lib,
}: {
  # This requires the host to manually import lanzaboote currently
  environment.systemPackages = [pkgs.sbctl];
  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      grub.enable = lib.mkForce false;
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      settings = {
        console-mode = "max";
        timeout = 0;
      };
    };
  };
}
