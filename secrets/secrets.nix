let
  lsanche = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJFc7O+5G6fwpXv9j/miJzST6g1AKkPTFtKwuj6j8NC+";

  allUsers = [ lsanche ];

  neo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInbvz+y3qiKY/TtE7pgj0zHhsf0+DpBixNpYVsKIU9z";
  morpheus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJwom9wkcct1EcBiLga22e4lJeQ2AhzNyCCGgjreUd/";
  oracle = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGmAZGffAeHZRi/RdVnti5KQxXxj99HkpcB04FVaHkdU";
  trinity = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMPzOIbBN0mEtrYA1edvKClxgrYGzauA7ea6ZMt3BLd";

  allSystems = [ neo morpheus oracle trinity ];
in
{
  "nebula.ca.crt.age".publicKeys = allUsers ++ allSystems;
  "fastmail.age".publicKeys = allUsers ++ [ neo morpheus ];

  "neo/nebula.key.age".publicKeys = [ lsanche neo ];
  "neo/nebula.crt.age".publicKeys = [ lsanche neo ];
  "neo/id_trinity_borg.age".publicKeys = [ lsanche neo ];
  "neo/pass_trinity_borg.age".publicKeys = [ lsanche neo ];

  "morpheus/nebula.key.age".publicKeys = [ lsanche morpheus ];
  "morpheus/nebula.crt.age".publicKeys = [ lsanche morpheus ];

  "oracle/nebula.key.age".publicKeys = [ lsanche oracle ];
  "oracle/nebula.crt.age".publicKeys = [ lsanche oracle ];

  "oracle/nc_db.age".publicKeys = [ lsanche oracle ];
  "oracle/nc_root_pw.age".publicKeys = [ lsanche oracle ];

  "trinity/nebula.key.age".publicKeys = [ lsanche trinity ];
  "trinity/nebula.crt.age".publicKeys = [ lsanche trinity ];

  "id_borgbase.age".publicKeys = allUsers ++ allSystems;

  "neo/pass_borgbase.age".publicKeys = allUsers ++ allSystems;
}
