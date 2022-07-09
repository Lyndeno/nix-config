let
  lsanche = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJFc7O+5G6fwpXv9j/miJzST6g1AKkPTFtKwuj6j8NC+";

  allUsers = [ lsanche ];

  neo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInbvz+y3qiKY/TtE7pgj0zHhsf0+DpBixNpYVsKIU9z";

  allSystems = [ neo ];
in
{
  "nebula.key.age".publicKeys = allUsers ++ allSystems;
  "nebula.crt.age".publicKeys = allUsers ++ allSystems;
  "nebula.ca.crt.age".publicKeys = allUsers ++ allSystems;
}
