{
  sudo = {
    execWheelOnly = true;
  };
  pam = {
    u2f = {
      enable = true;
      cue = true;
    };
    #enableSSHAgentAuth = true;
  };
}
