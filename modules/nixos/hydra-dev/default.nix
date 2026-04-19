{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age.secrets.hydra = {
    file = ../../../secrets/${config.networking.hostName}/hydra.age;
    owner = "hydra-www";
    group = "hydra";
    mode = "0440";
  };

  nix = {
    buildMachines = [
      {
        hostName = "localhost";
        protocol = null;
        systems = ["x86_64-linux" "aarch64-linux"];
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark" "gccarch-znver3" "gccarch-skylake"];
        maxJobs = 32;
      }
    ];
    settings = {
      allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
        "https://devimages-cdn.apple.com/"
      ];
      system-features = [
        "kvm"
        "nixos-test"
        "big-parallel"
        "benchmark"
        "gccarch-znver3"
        "gccarch-skylake"
      ];
    };
  };

  services = {
    hydra = {
      enable = true;
      hydraURL = "https://hydra.${config.networking.domain}";
      notificationSender = "hydra@${config.networking.hostName}";
      useSubstitutes = true;
      extraConfig = ''
        Include ${config.age.secrets.hydra.path}

        <githubstatus>
          #jobs = test:pr:build
          ## This example will match all jobs
          jobs = .*
          excludeBuildFromContext = 1
          useShortContext = 1
        </githubstatus>
      '';
    };

    localProxy.subDomains.hydra = {
      inherit (config.services.hydra) port;
      extraConfig.extraConfig = ''
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Port 443;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };
}
