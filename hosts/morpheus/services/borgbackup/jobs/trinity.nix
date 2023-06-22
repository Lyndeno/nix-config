{
  config,
  super,
}:
with config.age.secrets; {
  inherit (super.common) paths exclude;
  repo = "borg@trinity:.";
  encryption = {
    mode = "repokey-blake2";
    passCommand = "cat ${pass_trinity_borg.path}";
  };
  environment.BORG_RSH = "ssh -i ${id_trinity_borg.path}";
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
}
