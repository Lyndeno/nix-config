# gpu-coredump

Saves DRM device coredumps to persistent storage before the kernel deletes them.

## Why this exists

Morpheus' RX 6700 XT intermittently hangs its graphics ring and takes the whole
graphical session with it — screens black for a second or two, then back at GDM
with every application gone. As of August 2026 this happened roughly every one
to two days of active use.

The failure is always the same two-stage sequence. First, some client's shader
reads unmapped memory:

```
amdgpu: [gfxhub] page fault (src_id:0 ring:24 vmid:5 pasid:522)
amdgpu:  Process alacritty pid 2931230 thread alacritty:cs0
amdgpu:   in page starting at address 0x0000800901823000 from client 0x1b (UTCL2)
amdgpu:          Faulty UTCL2 client ID: TCP (0x8)
amdgpu:          PERMISSION_FAULTS: 0x3
```

Roughly ten seconds later the graphics ring times out, and recovery escalates:

```
amdgpu: ring gfx_0.1.0 timeout, signaled seq=2372840, emitted seq=2372842
amdgpu:  Process niri pid 947802 thread niri:cs0
amdgpu: Starting gfx_0.1.0 ring reset
amdgpu: Ring gfx_0.1.0 reset failed          <-- soft recovery fails
amdgpu: GPU reset begin!. Source:  1
amdgpu: MODE1 reset
amdgpu: VRAM is lost due to GPU reset!
```

The compositor is a bystander — it dies with `The CS has cancelled because the
context is lost. This context is innocent.` If the soft per-ring reset succeeded
you would see a brief stutter and nothing more; the escalation to a full MODE1
device reset is what loses VRAM and every GPU context on the system.

The faulting process has differed each time (`python3.13`, then `alacritty`),
which points at the userspace driver rather than any one application. Confirming
that, and filing anything actionable upstream, needs the coredump.

## The problem this module solves

When amdgpu detects the hang it writes a coredump and says so:

```
amdgpu: [drm] AMDGPU device coredump file has been created
amdgpu: [drm] Check your /sys/class/drm/card1/device/devcoredump/data
```

The kernel then deletes it about five minutes later (`DEVCD_TIMEOUT`). Since the
session has just been destroyed, five minutes is spent logging back in and
reopening windows — the dump is reliably gone before anyone thinks to look. It
cannot be caught by hand.

So a udev rule catches the node the instant it appears.

## How it works

```
ACTION=="add", SUBSYSTEM=="devcoredump", TAG+="systemd", \
  ENV{SYSTEMD_WANTS}+="gpu-coredump-capture@%k.service"
```

The rule hands off to a systemd unit rather than doing the copy in `RUN+=`.
udev runs `RUN+=` synchronously against the event queue, and stalling that queue
while reading tens of megabytes — at the exact moment the GPU is already wedged
and devices are being torn down and re-probed — is a bad trade for the small
amount of indirection saved.

Each capture writes two files to `/var/lib/gpu-coredumps/`:

| File | Contents |
| --- | --- |
| `<timestamp>-devcdN.dump.gz` | The coredump itself, gzipped |
| `<timestamp>-devcdN.kmsg` | The last 300 lines of kernel log |

The `.kmsg` sidecar is not an afterthought. The dump is written when the hang is
detected, *before* the reset, so at capture time the kernel ring buffer still
holds the page faults that led up to it — including the `Process <name>` lines
identifying the guilty client. That context is what makes the dump interpretable,
and it is the part that was lost on the August 16th event.

Nothing is deleted from sysfs, so the kernel's own expiry is unaffected.

## Reading a capture

```bash
ls -la /var/lib/gpu-coredumps/

# Which process faulted, and what the driver did about it
grep -E 'Process|ring .* timeout|reset' /var/lib/gpu-coredumps/<timestamp>-devcd0.kmsg

# The dump itself: register state, ring contents, the faulting shader
zcat /var/lib/gpu-coredumps/<timestamp>-devcd0.dump.gz | less
```

The thing to watch across several captures is whether the faulting process keeps
changing. Different applications hitting an identical fault signature is evidence
the bug is in Mesa (26.1.5 at time of writing, on kernel 6.18.43) rather than in
any particular application.

## Options

| Option | Default | Purpose |
| --- | --- | --- |
| `services.gpuCoredump.enable` | `false` | Install the rule and unit |
| `services.gpuCoredump.outputDir` | `/var/lib/gpu-coredumps` | Where captures land |
| `services.gpuCoredump.maxDumps` | `20` | Captures retained; older pairs pruned after each run |
| `services.gpuCoredump.sourceDir` | `/sys/class/devcoredump` | Where devcoredump nodes appear |

Retention is a real concern rather than tidiness: a GPU stuck in a reset loop
would otherwise write dumps until the filesystem fills.

`sourceDir` exists so the test can point at a fixture directory instead of real
sysfs. It should not need changing on a live host.

## Scope

The udev rule matches the `devcoredump` subsystem as a whole, not amdgpu
specifically — the failing driver is not exposed as a property on the devcd node
in a form worth matching against. Any driver that produces a devcoredump will
therefore be captured too (some wireless firmware does this). On these hosts
amdgpu is the only producer in practice, and `maxDumps` bounds the cost either
way.

## Testing

`checks/gpu-coredump.nix` covers everything downstream of the udev event: the
capture service, the compressed dump, the `.kmsg` sidecar, retention pruning, the
race where the kernel expires the node first, and that the rule is installed.

A real devcoredump can only be produced by a driver hitting an actual hardware
hang, which a VM cannot stage, so the test points `sourceDir` at a fixture
directory. The udev rule firing against live hardware is consequently the one
part not covered.

```bash
nix build .#checks.x86_64-linux.gpu-coredump
```

## Retiring this

This module is diagnostic scaffolding for a specific open bug. Once the ring
hangs are resolved — most likely by a Mesa or kernel version change — drop
`services.gpuCoredump.enable` from the host, and remove the module if nothing
else has come to depend on it.
