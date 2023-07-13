{
  rtkit.enable = true; # Realtime pipewire
  pam.services = {
    login.u2fAuth = false;
    sddm.u2fAuth = false;
    sddm.enableGnomeKeyring = true;
  };
}
