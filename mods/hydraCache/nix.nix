{
  settings = {
    substituters = [
      "http://morpheus:5000"
    ];
  };
  extraOptions = ''
    max-substitution-jobs = 128
    http-connections = 128
  '';
  binaryCachePublicKeys = [
    "morpheus:sENQ8rUrJnNC5eLSBAfXuWouftFrVFjB5V7FCbDXb+M="
  ];
}
