{
  lsanche = {
    morpheus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEjPlzlPcny6ZKwNzdlzi85lrIhPtdjLDRov29Fbef60";
    neo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtYA9xm9hQtFt5r7WuED1kkmvfezCURg6Tx9Ch1q0Ie";
    oracle = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG8hU9yYrAg76q1zp6rfhOBxSjwSwzQFpJTdBynWSCKA";
    trinity = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIGB5Ui/De31w1o/Z6ce0gNt6LDC+1W1skbNtQrw4DE6";
  };

  # Authorized keys for remote builders connecting INTO a host (sshUser = builder).
  builders = {
    morpheus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+/C/kSJUTqvnRXdq86551K1k1x1YG57Oc68b9nDsED";
  };

  # SSH host public keys (the `/etc/ssh/ssh_host_*_key.pub` of each host).
  # Used by remote build clients to verify they're talking to the right server.
  hostKeys = {
    morpheus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJwom9wkcct1EcBiLga22e4lJeQ2AhzNyCCGgjreUd/ root@morpheus";
  };
}
