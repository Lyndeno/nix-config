{
  settings = {
    substituters = [
      "https://cache.lyndeno.ca/main"
    ];
    trusted-public-keys = [
      "main:syNgLPFLeX/wWUxGh7SWMW8wuOPVhEkC9HIhIl7NXQQ="
    ];
  };
  extraOptions = ''
    max-substitution-jobs = 128
    http-connections = 128
  '';
}
