# Exercises the gpu-coredump module. A real devcoredump can only be produced by
# a driver hitting a hardware hang, which a VM cannot stage, so the module's
# sourceDir is pointed at a fixture directory standing in for sysfs. That covers
# everything downstream of the udev event: the capture service, the compressed
# dump, the kernel log sidecar, and retention pruning.
{
  flake,
  pkgs,
  ...
}:
pkgs.testers.nixosTest {
  name = "gpu-coredump";

  nodes.machine = {
    imports = [flake.nixosModules.gpu-coredump];

    services.gpuCoredump = {
      enable = true;
      sourceDir = "/run/fake-devcoredump";
      maxDumps = 2;
    };

    system.stateVersion = "25.11";
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")

    # Stand in for the sysfs node the kernel would create on a GPU hang.
    machine.succeed("mkdir -p /run/fake-devcoredump/devcd0")
    machine.succeed("echo 'AMDGPU-COREDUMP-PAYLOAD' > /run/fake-devcoredump/devcd0/data")

    machine.succeed("systemctl start gpu-coredump-capture@devcd0.service")

    # The dump is stored compressed, with the kernel log context beside it.
    dump = machine.succeed("ls /var/lib/gpu-coredumps/*.dump.gz").strip()
    assert "devcd0" in dump, dump
    payload = machine.succeed(f"zcat {dump}")
    assert "AMDGPU-COREDUMP-PAYLOAD" in payload, payload
    machine.succeed("ls /var/lib/gpu-coredumps/*.kmsg")

    # A vanished node must not fail the unit; the kernel expires dumps on its
    # own schedule and may win the race.
    machine.succeed("rm /run/fake-devcoredump/devcd0/data")
    machine.succeed("systemctl start gpu-coredump-capture@devcd0.service")

    # Retention: with maxDumps = 2, a third capture evicts the oldest pair.
    machine.succeed("echo payload > /run/fake-devcoredump/devcd0/data")
    for _ in range(3):
        # Timestamps have second resolution, so space the captures out to keep
        # the filenames distinct.
        machine.succeed("sleep 1; systemctl start gpu-coredump-capture@devcd0.service")

    assert machine.succeed("ls -1 /var/lib/gpu-coredumps/*.dump.gz | wc -l").strip() == "2"
    assert machine.succeed("ls -1 /var/lib/gpu-coredumps/*.kmsg | wc -l").strip() == "2"

    # The udev rule that drives all of the above in production must be installed.
    rules = machine.succeed("cat /etc/udev/rules.d/*.rules")
    assert "SUBSYSTEM==\"devcoredump\"" in rules, rules
    assert "gpu-coredump-capture@" in rules, rules
  '';

  # VM test only makes sense on x86_64; keep it off emulated aarch64 builders.
  meta.platforms = ["x86_64-linux"];
}
