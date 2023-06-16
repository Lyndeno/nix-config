{
  enable = true;
  settings = {
    # Disable password authentication
    KbdInteractiveAuthentication = false;
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };
}
