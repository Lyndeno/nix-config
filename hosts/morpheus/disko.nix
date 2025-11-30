{
  disko.devices = {
    disk = {
      mirror_a = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_2TB_23037F460708";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "fastmirror";
              };
            };
          };
        };
      };
      mirror_b = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_2TB_223903800825";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "fastmirror";
              };
            };
          };
        };
      };
    };
    zpool = {
      fastmirror = {
        type = "zpool";
        mode = "mirror";
        # Workaround: cannot import 'zroot': I/O error in disko tests
        #options.cachefile = "none";
        options.ashift = "12";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = null;

        datasets = {
          encrypt = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              compression = "zstd";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file:///fastmirror_key";
            };
            # use this to read the key during boot
            # postCreateHook = ''
            #   zfs set keylocation="prompt" "zroot/$name";
            # '';
          };
          "encrypt/services" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              compression = "zstd";
            };
          };
          #"encrypt/services/pgsql_16" = {
          #  type = "zfs_fs";
          #  options = {
          #    mountpoint = "legacy";
          #    compression = "zstd";
          #    recordsize = "16k";
          #  };
          #  mountpoint = "/var/lib/postgresql/16";
          #};
          "encrypt/services/ollama" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              compression = "zstd";
            };
            mountpoint = "/var/lib/private/ollama";
          };
        };
      };
    };
  };
}
