{
  nix = {
    settings = {
      substituters = [
        "https://cache.lyndeno.ca/main"
      ];
      trusted-public-keys = [
        "main:8u0J28gcg55zBSKs31FSY3PGb/wH+DQZX+gJbjvQI6M="
      ];
    };
    extraOptions = ''
      max-substitution-jobs = 128
      http-connections = 128
    '';
  };
}
