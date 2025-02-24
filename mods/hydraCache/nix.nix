{
  settings = {
    substituters = [
      "https://hydra.lyndeno.ca"
    ];
    trusted-public-keys = [
      "morpheus:sENQ8rUrJnNC5eLSBAfXuWouftFrVFjB5V7FCbDXb+M="
    ];
  };
  extraOptions = ''
    max-substitution-jobs = 128
    http-connections = 128
  '';
}
