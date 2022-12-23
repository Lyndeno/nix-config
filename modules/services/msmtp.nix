{config, pkgs, lib, ...}:

let
  cfg = config.modules.services.msmtp;
in
{
  options.modules.services.msmtp = {
    enable = lib.mkEnableOption "System mailer";
  };

  config = lib.mkIf cfg.enable {
    age.secrets.gmail_pass.file = ../../secrets/email_pass.age;
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
          host = "smtp.gmail.com";
          passwordeval = "${pkgs.busybox}/bin/cat ${config.age.secrets.gmail_pass.path}";
          user = "lyndeno@gmail.com";
          from = "${config.networking.hostName}@lyndeno.ca";
        };
      };
    };
  };
}