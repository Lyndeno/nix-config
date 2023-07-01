{pkgs}: {
  description = "Spin down disks";
  wantedBy = ["multi-user.target"];
  serviceConfig = {
    ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 3600";
  };
}
