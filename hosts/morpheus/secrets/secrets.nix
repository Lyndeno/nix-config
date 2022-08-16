let
  lsanche = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJFc7O+5G6fwpXv9j/miJzST6g1AKkPTFtKwuj6j8NC+";

  allUsers = [ lsanche ];

  morpheus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJwom9wkcct1EcBiLga22e4lJeQ2AhzNyCCGgjreUd/";

  allSystems = [ morpheus ];
in
{
  "nebula.key.age".publicKeys = allUsers ++ allSystems;
  "nebula.crt.age".publicKeys = allUsers ++ allSystems;
  "nebula.ca.crt.age".publicKeys = allUsers ++ allSystems;
}
