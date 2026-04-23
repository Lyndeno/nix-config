{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.self.nixosModules.msmtp
  ];
  systemd = {
    settings.Manager = {
      RuntimeWatchdogSec = "60s";
    };
    sleep.settings.Sleep = {
      AllowSuspend = false;
      AllowHibernation = false;
      AllowSuspendThenHibernate = false;
      AllowHybridSleep = false;
    };
  };

  networking.firewall.logRefusedConnections = false;

  services = {
    # May not be on a server but just in case
    displayManager.gdm.autoSuspend = false;
    # Keep cats from shutting down
    logind.settings.Login.HandlePowerKey = "ignore";
    # Headless notifications
    smartd = {
      enable = true;
      notifications.mail = {
        sender = "${config.networking.hostName}@${config.networking.domain}";
        recipient = "lsanche@lyndeno.ca";
        enable = true;
      };
      # Short self test every week at 2AM
      # Long self test every month on the 5th at 4AM
      #defaults.monitored = "-a -o on -s (S/../../7/02|L/../05/../04)";
    };
    tailscale.useRoutingFeatures = "both";
  };
}
