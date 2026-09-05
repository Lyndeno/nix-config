# Full backup/restore integration test for the borgmatic (services.hostBackup)
# module. Three VMs stand in for the real topology:
#
#   repo    - hosts the Borg repository over SSH (stands in for Borgbase)
#   origin  - runs services.hostBackup; backs up files + a Postgres cluster
#   restore - a clean machine that restores from the same repository
#
# It exercises the whole chain end to end: the module's generated borgmatic
# config, the systemd-run-wrapped pg_dumpall stream, borg-over-SSH, and a
# restore of both files and databases onto a *different* host.
#
# The repository lives in-VM (NixOS tests have no internet), and a throwaway
# SSH key and passphrase are baked in - both are test-only and never touch the
# real Borgbase repo or agenix secrets.
{
  flake,
  pkgs,
  ...
}: let
  # Throwaway ed25519 key pair, generated for this test only.
  privateKey = ''
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
    QyNTUxOQAAACB2nSpOVCDq2ZhHizxlWeUQpEm0r9N3sEO/UPJpILmCawAAAKB3veZvd73m
    bwAAAAtzc2gtZWQyNTUxOQAAACB2nSpOVCDq2ZhHizxlWeUQpEm0r9N3sEO/UPJpILmCaw
    AAAEARfILiQIk/CXyR0flJXte5T/DxpGZErl4c3CMjXdhiP3adKk5UIOrZmEeLPGVZ5RCk
    SbSv03ewQ79Q8mkguYJrAAAAGmJvcmdtYXRpYy12bXRlc3QtdGhyb3dhd2F5AQID
    -----END OPENSSH PRIVATE KEY-----
  '';
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHadKk5UIOrZmEeLPGVZ5RCkSbSv03ewQ79Q8mkguYJr borgmatic-vmtest-throwaway";

  passphrase = "correct-horse-battery-staple";
  repository = "ssh://borg@repo/./repo";

  # Configuration shared by the machines that talk to the repository.
  client = {lib, ...}: {
    imports = [flake.nixosModules.borgmatic];

    environment = {
      systemPackages = [pkgs.borgmatic pkgs.borgbackup];
      etc = {
        "borg/pass".text = passphrase;
        "borg/id" = {
          text = privateKey;
          mode = "0600";
        };
      };
    };

    # Drive backups explicitly from the test script; don't let the timer fire
    # an unplanned run at boot that races the repo setup.
    systemd.timers.borgmatic.wantedBy = lib.mkForce [];
    # Skip the packaged unit's 60s "settle before backup" ExecStartPre sleep.
    systemd.services.borgmatic.serviceConfig.ExecStartPre = lib.mkForce [];

    # Test-only: skip host-key verification so borg's ssh connects unattended.
    programs.ssh.extraConfig = ''
      Host *
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
    '';

    services = {
      postgresql.enable = true;

      # borgmatic filters archives to the current host's series (the default
      # archive_name_format embeds {hostname}). Pin a shared, hostname-neutral
      # series so the restore host can see the origin host's archives - the
      # whole point of a restore-elsewhere test.
      borgmatic.settings.archive_name_format = "backup-{now:%Y-%m-%dT%H:%M:%S.%f}";

      hostBackup = {
        enable = true;
        inherit repository;
        passCommand = "cat /etc/borg/pass";
        sshKey = "/etc/borg/id";
        # Matches the morpheus config: whole-cluster pg_dumpall, atticd excluded.
        postgresqlDatabases = [
          {
            name = "all";
            username = "postgres";
            options = "--exclude-database=atticd";
          }
        ];
      };
    };

    system.stateVersion = "25.11";
  };
in
  pkgs.testers.nixosTest {
    name = "borgmatic-backup-restore";

    nodes = {
      repo = {
        services.openssh.enable = true;
        users.users.borg = {
          isNormalUser = true;
          openssh.authorizedKeys.keys = [publicKey];
        };
        # borg-over-SSH runs `borg serve` on the remote, so it must be on PATH.
        environment.systemPackages = [pkgs.borgbackup];
        system.stateVersion = "25.11";
      };

      origin = {imports = [client];};
      restore = {imports = [client];};
    };

    testScript = ''
      start_all()
      repo.wait_for_unit("sshd.service")
      origin.wait_for_unit("postgresql.service")

      with subtest("seed data on origin"):
          origin.succeed("runuser -u postgres -- psql -c 'CREATE DATABASE canary'")
          origin.succeed(
              "runuser -u postgres -- psql -d canary -c "
              "\"CREATE TABLE marker (val text); INSERT INTO marker VALUES ('backup-canary')\""
          )
          origin.succeed("mkdir -p /srv && echo file-canary > /srv/canary.txt")

      with subtest("initialise repository and back up from origin"):
          origin.succeed("borgmatic repo-create --encryption repokey-blake2")
          # Runs the real systemd unit: sandbox + systemd-run pg_dumpall stream.
          origin.succeed("systemctl start borgmatic.service")
          archives = origin.succeed("borgmatic list --json")
          assert "backup-" in archives, f"no archive created: {archives}"

      with subtest("restore databases onto the clean machine"):
          restore.wait_for_unit("postgresql.service")
          restore.succeed("borgmatic restore --archive latest")
          restore.wait_until_succeeds(
              "runuser -u postgres -- psql -d canary -tAc 'SELECT val FROM marker' "
              "| grep -q backup-canary"
          )

      with subtest("restore a file onto the clean machine"):
          restore.succeed("mkdir -p /tmp/restored")
          restore.succeed(
              "borgmatic extract --archive latest --path srv/canary.txt "
              "--destination /tmp/restored"
          )
          restore.succeed("grep -q file-canary /tmp/restored/srv/canary.txt")
    '';

    # VM test only makes sense on x86_64; keep it off emulated aarch64 builders.
    meta.platforms = ["x86_64-linux"];
  }
