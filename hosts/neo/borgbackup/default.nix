{config, ...}:
with config.age.secrets; {
  services.hostBackup = {
    enable = true;
    repository = "f774k1bg@f774k1bg.repo.borgbase.com:repo";
    passCommand = "cat ${pass_borgbase.path}";
    sshKey = id_borgbase.path;
    startAt = "hourly";
    acPowerOnly = true;
    # Laptop: skip the "data" check, which reads/re-verifies every chunk (a
    # full repo download). Keep the cheap structural + metadata checks.
    # Run a full data verification by hand when on wifi and plugged in:
    #   sudo borgmatic check --only data --force
    checks = [
      {
        name = "repository";
        frequency = "1 day";
      }
      {
        name = "archives";
        frequency = "1 week";
      }
    ];
  };
}
