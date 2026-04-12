{
  inputs,
  flake,
  ...
}: {
  imports = with flake.nixosModules; [
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    xps-9560
    common
    virtualisation
    desktop
    niri
    secureboot
    laptop
    hydraCache
    attic-watch
    ./borgbackup/borgbase.nix
    ./disko.nix
  ];

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIDNTCCAh2gAwIBAgIUJZD8PHnsrzxrvhHwmvCPMRbCkBUwDQYJKoZIhvcNAQEL
      BQAwKDESMBAGA1UEAwwJbWl0bXByb3h5MRIwEAYDVQQKDAltaXRtcHJveHkwHhcN
      MjYwNDA5MjMyODQ4WhcNMzYwNDA4MjMyODQ4WjAoMRIwEAYDVQQDDAltaXRtcHJv
      eHkxEjAQBgNVBAoMCW1pdG1wcm94eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
      AQoCggEBAMQFc9x1rNHDUSQRoMue+mGwr8r36ea8cvR27CV1NPVHVIgPq9wJz8/N
      UYZOK8i7ZnKEfwWpGfc8GWrFEVKQjItU43/1RU3okm2+sZp0rcntKJBUfJ200ekc
      Cb1AYcRrwF9w3OA7iKYd3dTb7s7qy8o1W7nexZUHtRpEEmXoHJNkzijlDEvfL+Ux
      JGL8iqwai+gEmPOhLhvMioWdYVkJUueBcBKFILZI8kLSlL4bRChGGpEKTEunuL9G
      SoFgF1P9kno3oTHam2yAAKmYtX0xWhhXIFNImAnPRecGXbhAcJEBUjihE3oE7NKO
      qiPBr/vfUqQodVcIGufX0/grozY1E2UCAwEAAaNXMFUwDwYDVR0TAQH/BAUwAwEB
      /zATBgNVHSUEDDAKBggrBgEFBQcDATAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYE
      FFOZCYjhHem6pwvcLBtzvogsKVyJMA0GCSqGSIb3DQEBCwUAA4IBAQBVj3aiIeZ2
      p5hLCTkZcQyFoieJx0CfglqmINAbWH9JBumwrqkj0Ki7wBP16IKOCoWJLhKoTf4i
      KIV9z4ZTpDa8OkUGS7Qq9vCw51IKr/azb6DLnzEchI0sMqWSK71KApyKre1dpCIG
      TNc/8peCFQHEcZxwKQY5ShXvp63HeOUw2Mv2Mp2Q9dFCCRhnoJnr6dkfLQnHe1V1
      ZeidrALNL8Rh6ppLcqYmQumydQ0TMzT8nZh/VDCsVj+YlzdYTiOhE4dU3jyLYP2D
      F4EaoNxJZv7x+2ki1vBML4p2SbIUJwTRsvWWE9FE59AC720Sc9T+pnPmVYhkUYXq
      7xzQahdTxder
      -----END CERTIFICATE-----
    ''
  ];

  system.stateVersion = "21.11";

  nixpkgs.hostPlatform = "x86_64-linux";

  age = {
    secrets = {
      id_borgbase.file = ../../secrets/id_borgbase.age;
      pass_borgbase.file = ../../secrets/neo/pass_borgbase.age;
    };
  };

  boot = {
    swraid.enable = false;
    initrd = {
      systemd = {
        enable = true;
      };
    };
    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  networking.hostName = "neo";

  systemd = {
    services.borgbackup-job-borgbase.unitConfig.ConditionACPower = true;
  };
}
