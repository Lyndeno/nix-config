{config}: {
  enable = true;
  openFirewall = true;
  secretKeyFile = config.age.secrets.nix-serve.path;
}
