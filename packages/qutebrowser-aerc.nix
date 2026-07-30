{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;

  config-py = pkgs.writeText "${pname}-config.py" ''
    import os

    # Reuse the user's main qutebrowser config in this throwaway instance.
    config_home = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    config.source(os.path.join(config_home, "qutebrowser", "config.py"))
    config.bind("q", "tab-close")
  '';
in
  pkgs.writeShellApplication {
    name = pname;

    text = ''
      exec ${lib.getExe pkgs.qutebrowser} \
        --desktop-file-name ${pname} \
        --basedir "/tmp/${pname}-''${UID}" \
        --config-py "${config-py}" \
        --target window \
        "$@"
    '';

    meta.platforms = lib.platforms.linux;
  }
