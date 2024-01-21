_: {
  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "2G";
              label = "ESP";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              label = "luks";
              content = {
                type = "luks";
                name = "crypted";
                extraOpenArgs = ["--allow-discards"];
                content = {
                  type = "lvm_pv";
                  vg = "nixpool";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      nixpool = {
        type = "lvm_vg";
        lvs = {
          nixroot = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                #"@nixos" = { mountpoint = null; };
                "@nixos/root" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "@nixos/home" = {
                  mountpoint = "/home";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                #"@nixos/var" = { mountpoint = null; };
                "@nixos/var/log" = {
                  mountpoint = "/var/log";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "@nixos/var/lib" = {
                  mountpoint = "/var/lib";
                  mountOptions = ["compress=zstd" "noatime"];
                };
              };
            };
          };
        };
      };
    };
  };
  boot.initrd.luks.devices.crypted.allowDiscards = true;
}
