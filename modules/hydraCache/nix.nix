{
  settings = {
    substituters = [
      "https://cache.lyndeno.ca/main"
    ];
    trusted-public-keys = [
      "main:rsW5Mmzo9fABvXSPOKJQeaJWXVpLSb8vZivRw4d/TaQ="
    ];
  };
  extraOptions = ''
    max-substitution-jobs = 128
    http-connections = 128
  '';
}
