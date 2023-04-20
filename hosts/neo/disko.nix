{...}: {
	disko.devices = {
		disk = {
			nvme = {
				type = "disk";
				device = "/dev/nvme0n1";
				content = {
					type = "table";
					format = "gpt";
					partitions = [
						{
							name = "ESP";
							start = "1MiB";
							end = "2GiB";
							bootable = true;
							content = {
								type = "filesystem";
								format = "vfat";
								mountpoint = "/boot";
								mountOptions = [
									"defaults"
								];
							};
						}
						{
							name = "luks";
							start = "2GiB";
							end = "100%";
							content = {
								type = "luks";
								name = "crypted";
								extraOpenArgs = [ "--allow-discards" ];
								content = {
									type = "lvm_pv";
									vg = "nixpool";
								};
							};
						}
					];
				};
			};
		};
		lvm_vg = {
			nixpool = {
				type = "lvm_vg";
				lvs = {
					nixswap = {
						size = "64G";
						content = {
							type = "swap";
						};
					};
					nixroot = {
						size = "1.75T";
						content = {
							type = "btrfs";
							extraArgs = [ "-f" ];
							subvolumes = {
								"@nix" = {
									mountpoint = "/nix";
									mountOptions = [ "compress=zstd" "noatime" ];
								};
								"@persist" = {
									mountpoint = "/persist";
									mountOptions = [ "compress=zstd" "noatime" ];
								};
							};
						};
					};
				};
			};
		};
		nodev = {
			"/" = {
				fsType = "tmpfs";
				mountOptions = [
					"defaults"
					"mode=755"
				];
			};
		};
	};
}
