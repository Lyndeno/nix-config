{
  nix.settings = {
    substituters = [
      "https://cache.lyndeno.ca"
    ];
    trusted-public-keys = [
      "morpheus:sENQ8rUrJnNC5eLSBAfXuWouftFrVFjB5V7FCbDXb+M="
    ];
  };
  nix.extraOptions = ''
    max-substitution-jobs = 128
    http-connections = 128
  '';
}
