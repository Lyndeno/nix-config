{
  pkgs,
  pname,
}: let
  inherit (pkgs) lib;
  package = pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = with pkgs; [
      acpi
      coreutils
    ];

    text = ''
      STATUS=$(acpi -a | cut -d" " -f3 | cut -d- -f1)
      if [ "$STATUS" = "off" ] || [ "$STATUS" = "on" ]
      then
        echo "$STATUS"
      else
        echo "n/a"
      fi
    '';

    meta.platforms = lib.platforms.linux;

    passthru.tests = {
      plugged-in = pkgs.testers.nixosTest {
        name = "battery-status-plugged-in";

        nodes.machine = _: {
          environment.systemPackages = [package];
          system.stateVersion = "25.11";
          boot.kernelModules = ["test_power"];
          boot.kernelParams = ["test_power.ac_online=on"];
        };

        testScript = ''
          import sys
          output = machine.execute("battery-status")
          if (output[1].strip() == "on"):
            sys.exit(0)
          else:
            sys.exit(-1)
        '';

        meta.platforms = ["x86_64-linux"];
      };
      unplugged = pkgs.testers.nixosTest {
        name = "battery-status-unplugged";

        nodes.machine = _: {
          environment.systemPackages = [package];
          system.stateVersion = "25.11";
          boot.kernelModules = ["test_power"];
          boot.kernelParams = ["test_power.ac_online=off"];
        };

        testScript = ''
          import sys
          output = machine.execute("battery-status")
          if (output[1].strip() == "off"):
            sys.exit(0)
          else:
            sys.exit(-1)
        '';

        meta.platforms = ["x86_64-linux"];
      };
      no-battery = pkgs.testers.nixosTest {
        name = "battery-status-no-battery";

        nodes.machine = _: {
          environment.systemPackages = [package];
          system.stateVersion = "25.11";
        };

        testScript = ''
          import sys
          output = machine.execute("battery-status")
          if (output[1].strip() == "n/a"):
            sys.exit(0)
          else:
            sys.exit(-1)
        '';

        meta.platforms = ["x86_64-linux"];
      };
    };
  };
in
  package
