{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];
  age.secrets.fastmail_pass.file = ../../../secrets/fastmail.age;
  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      aliases = "/etc/aliases";
      port = 465;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
      tls = "on";
      auth = "login";
      tls_starttls = "off";
    };
    accounts = {
      default = {
        host = "smtp.fastmail.com";
        passwordeval = "${pkgs.busybox}/bin/cat ${config.age.secrets.fastmail_pass.path}";
        user = "lsanche@fastmail.com";
        from = "${config.networking.hostName}@system.lyndeno.ca";
      };
    };
  };
}
