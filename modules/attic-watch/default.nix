{
  config,
  pkgs,
}: {
  systemd.services.attic-watch-store = {
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    environment.HOME = "/var/lib/attic-watch-store";
    serviceConfig = {
      Restart = "on-failure";
      DynamicUser = true;
      MemoryHigh = "5%";
      MemoryMax = "10%";
      LoadCredential = "prod-auth-token:${config.age.secrets.attic-auth.path}";
      StateDirectory = "attic-watch-store";
    };
    path = [pkgs.attic-client];
    script = ''
      set -eux -o pipefail
      ATTIC_TOKEN=$(< $CREDENTIALS_DIRECTORY/prod-auth-token)
      # Replace https://cache.<domain> with your own cache URL.
      attic login local http://localhost:8080 $ATTIC_TOKEN
      attic use local:main
      exec attic watch-store prod:main
    '';
  };
}
