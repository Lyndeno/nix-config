{config, ...}:
with config.age.secrets; {
  age.secrets = {
    id_borgbase.file = ../../../secrets/id_borgbase.age;
    pass_borgbase.file = ../../../secrets/morpheus/pass_borgbase.age;
  };

  services.borgbackup.jobs.borgbase = {
    inherit (import ./common.nix {inherit config;}) paths exclude;
    repo = "n2ikk4w3@n2ikk4w3.repo.borgbase.com:repo";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${pass_borgbase.path}";
    };
    environment.BORG_RSH = "ssh -i ${id_borgbase.path}";
    compression = "auto,zstd,10";
    startAt = "hourly";
    prune = {
      keep = {
        within = "3d";
        daily = 14;
        weekly = 4;
        monthly = -1;
      };
    };
  };
}
