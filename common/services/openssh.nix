{
  enable = true;
  startWhenNeeded = true;
  settings = {
    # Disable password authentication
    KbdInteractiveAuthentication = false;
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };
  openFirewall = false;
}
