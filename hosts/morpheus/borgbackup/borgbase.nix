{config, ...}:
with config.age.secrets; {
  services.borgbackup.jobs.borgbase = {
    inherit (import ./common.nix {inherit config;}) paths exclude;
    repo = "n2ikk4w3@n2ikk4w3.repo.borgbase.com:repo";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${pass_borgbase.path}";
    };
    #preHook = ''
    #  echo "save-off" > /run/minecraft-server.stdin
    #  echo "say Saving" > /run/minecraft-server.stdin
    #  echo "save-all" > /run/minecraft-server.stdin
    #  sleep 5
    #  echo "say Backing Up" > /run/minecraft-server.stdin
    #'';
    #postHook = ''
    #  echo "save-on" > /run/minecraft-server.stdin
    #'';
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
