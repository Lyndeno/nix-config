let
  lsanche = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJFc7O+5G6fwpXv9j/miJzST6g1AKkPTFtKwuj6j8NC+";

  allUsers = [lsanche];

  neo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInbvz+y3qiKY/TtE7pgj0zHhsf0+DpBixNpYVsKIU9z";
  morpheus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJwom9wkcct1EcBiLga22e4lJeQ2AhzNyCCGgjreUd/";
  oracle = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGmAZGffAeHZRi/RdVnti5KQxXxj99HkpcB04FVaHkdU";
  trinity = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMPzOIbBN0mEtrYA1edvKClxgrYGzauA7ea6ZMt3BLd";

  allSystems = [neo morpheus oracle trinity];
in {
  "fastmail.age".publicKeys = allUsers ++ [neo morpheus];
  "fastmail_jmap.age".publicKeys = allUsers ++ allSystems;
  "attic_auth.age".publicKeys = [lsanche neo morpheus];
  "vpn.age".publicKeys = [lsanche neo morpheus];

  "neo/id_trinity_borg.age".publicKeys = [lsanche neo];
  "neo/pass_trinity_borg.age".publicKeys = [lsanche neo];
  "neo/pangolin.age".publicKeys = [lsanche neo];

  "morpheus/pass_borgbase.age".publicKeys = [lsanche morpheus];
  "morpheus/id_trinity_borg.age".publicKeys = [lsanche morpheus];
  "morpheus/pass_trinity_borg.age".publicKeys = [lsanche morpheus];
  "morpheus/webdav.age".publicKeys = [lsanche morpheus];
  "morpheus/firefly_id.age".publicKeys = [lsanche morpheus];
  "morpheus/attic_token.age".publicKeys = [lsanche morpheus];
  "morpheus/garage.age".publicKeys = [lsanche morpheus];
  "morpheus/pangolin.age".publicKeys = [lsanche morpheus];
  "morpheus/immich.age".publicKeys = [lsanche morpheus];
  "morpheus/hydra.age".publicKeys = [lsanche morpheus];

  "oracle/nc_db.age".publicKeys = [lsanche oracle];
  "oracle/nc_root_pw.age".publicKeys = [lsanche oracle];

  "id_borgbase.age".publicKeys = allUsers ++ allSystems;

  "email_pass.age".publicKeys = allUsers ++ allSystems;

  "neo/pass_borgbase.age".publicKeys = allUsers ++ allSystems;

  "zed_pushover.age".publicKeys = allUsers ++ allSystems;
  "zed_user.age".publicKeys = allUsers ++ allSystems;
}
