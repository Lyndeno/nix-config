{
  rtkit.enable = true; # Realtime pipewire
  pam.services = {
    login.u2fAuth = false;
    gdm.u2fAuth = false;
  };
}
