{
  sudo = {
    execWheelOnly = true;
  };
  pam = {
    u2f = {
      enable = true;
      settings.cue = true;
    };
    #enableSSHAgentAuth = true;
  };
}
