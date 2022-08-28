let
  lsanche = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJFc7O+5G6fwpXv9j/miJzST6g1AKkPTFtKwuj6j8NC+";

  allUsers = [ lsanche ];

  trinity = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMPzOIbBN0mEtrYA1edvKClxgrYGzauA7ea6ZMt3BLd";

  allSystems = [ trinity ];
in
{
  "nebula.key.age".publicKeys = allUsers ++ allSystems;
  "nebula.crt.age".publicKeys = allUsers ++ allSystems;
  "nebula.ca.crt.age".publicKeys = allUsers ++ allSystems;
}
