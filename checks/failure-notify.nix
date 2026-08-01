# Exercises the failure-notify module end to end: a deliberately failing unit
# should trigger the OnFailure= handler, which renders and "sends" an e-mail.
# The delivery command is overridden to capture the message to a file, which is
# then shipped as a build artifact (failure-notify-sample.eml in $out) so the
# rendered mail can be inspected.
{
  flake,
  pkgs,
  ...
}:
pkgs.testers.nixosTest {
  name = "failure-notify";

  nodes.machine = {
    imports = [flake.nixosModules.failure-notify];

    networking.domain = "example.test";

    # A unit guaranteed to fail, wired through the notifier.
    systemd.services.canary = {
      description = "Deliberately failing unit for the failure-notify test";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/false";
      };
    };

    services.failureNotify = {
      enable = true;
      recipient = "ops@example.test";
      units = ["canary"];
      # Capture the rendered message instead of sending it over SMTP.
      sendmailCommand = "${pkgs.coreutils}/bin/tee /var/lib/failure-notify-sample.eml";
    };

    system.stateVersion = "25.11";
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # Trigger the failure; the unit is expected to fail, which fires the
    # OnFailure= handler asynchronously.
    machine.fail("systemctl start canary.service")

    # Wait for the handler to render and capture the message.
    machine.wait_until_succeeds("test -s /var/lib/failure-notify-sample.eml")

    email = machine.succeed("cat /var/lib/failure-notify-sample.eml")
    assert "Subject: [machine] Unit failed: canary.service" in email, email
    assert "To: ops@example.test" in email, email
    assert "entered a failed state" in email, email
    assert "canary.service" in email, email

    # Ship the rendered e-mail as a build artifact.
    machine.copy_from_vm("/var/lib/failure-notify-sample.eml", "")
  '';

  # VM test only makes sense on x86_64; keep it off emulated aarch64 builders.
  meta.platforms = ["x86_64-linux"];
}
