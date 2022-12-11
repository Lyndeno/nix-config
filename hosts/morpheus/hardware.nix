{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "mpt3sas" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" "jc42" "nct6775" ];
  boot.extraModulePackages = [ ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "a5d4421d";

  age.secrets.gmail_pass.file = ../../secrets/email_pass.age;
  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      aliases = "/etc/aliases";
      port = 465;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
      tls = "on";
      auth = "login";
      tls_starttls = "off";
    };
    accounts = {
      default = {
        host = "smtp.gmail.com";
        passwordeval = "cat ${config.age.secrets.gmail_pass.path}";
        user = "lyndeno@gmail.com";
        from = "morpheus@lyndeno.ca";
      };
    };
  };

  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;

  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_EMAIL_ADDR = [ "lsanche@lyndeno.ca" ];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
  };
  services.zfs.zed.enableMail = false;

  fileSystems = {
  "/" =
    { device = "nixpool/nixos/root";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  "/home" =
    { device = "nixpool/nixos/home";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  "/var" =
    { device = "nixpool/nixos/var";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  "/var/lib" =
    { device = "nixpool/nixos/var/lib";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  "/var/log" =
    { device = "nixpool/nixos/var/log";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

	  "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    "/data/mirror" = {
      device = "/dev/disk/by-label/mirrorpool";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd:6" ];
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-label/nixswap"; }
    ];
}
