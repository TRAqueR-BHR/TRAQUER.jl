# Julia worker cleanup

`scripts/add-procs.jl` creates Julia `Distributed` worker processes for local
development sessions. Those workers can survive when the master Julia process is
killed abruptly, especially from VS Code or with `SIGKILL`.

The cleanup logic intentionally has several layers because no single mechanism
covers every shutdown mode.

## Normal shutdown

When the master Julia process exits normally, Julia runs `atexit` hooks. The hook
registered in `scripts/add-procs.jl` calls `rmprocs(...)` so workers are removed
through Julia's `Distributed` API.

This is the cleanest path, but it does not run when the master is killed with
`SIGKILL` or when the process is otherwise terminated without Julia cleanup.

## Local OS parent watchdog

Each worker starts a small shell process. That shell process periodically checks
the worker's parent PID. If the parent PID changes, the worker has been orphaned
or re-parented, so the shell watchdog terminates the worker.

This exists because a Julia `@async` watchdog on the worker is not always enough:
an idle worker may be blocked inside `Distributed` internals and not schedule the
Julia task quickly after the master process disappears.

This is expected to work for local workers and for remote workers whose remote
launcher/SSH parent disappears when the master connection is lost.

## Distributed heartbeat fallback

Each worker also starts a Julia task that periodically calls process `1`, the
Julia master process, using `remotecall_fetch`. This is useful for remote workers
because OS process IDs are local to each machine and cannot be compared across a
cluster.

If the master process is unreachable, the heartbeat fails or times out and the
worker exits itself.

This fallback may depend on the worker being able to schedule Julia tasks. The OS
watchdog is therefore kept as the more reliable local hard-kill path.

## Startup cleanup safety net

`scripts/prerequisite.jl` also calls
`scripts/cleanup-orphaned-julia-processes.sh` before adding new workers. That
script removes orphaned Julia worker processes left behind by previous sessions.

This is intentionally a safety net, not the primary cleanup mechanism.
