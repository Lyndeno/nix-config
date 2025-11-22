{
  settings = {
    substituters = [
      "https://cache.lyndeno.ca/main"
    ];
    trusted-public-keys = [
      "main:cA2LVXhKXjabZQLd+MsodW8qmMYh3IXf6T2k1KI6PUE="
    ];
  };
  extraOptions = ''
    max-substitution-jobs = 128
    http-connections = 128
  '';
}
