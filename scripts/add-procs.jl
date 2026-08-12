# Add the configured number of Julia worker processes.
#
# Worker cleanup is intentionally defensive. See `scripts/worker-cleanup.md` for
# a longer explanation of the failure modes this file handles.
using Distributed

"""
    get_worker_ids()

Return the ids of active Julia worker processes, excluding the main process.
"""
function get_worker_ids()
    # `workers()` may return `[1]` when no worker process exists. Keep only real
    # worker processes so shutdown cleanup does not try to remove the main proc.
    return [workerId for workerId in workers() if workerId != myid()]
end

"""
    install_parent_process_watchdog()

Install a watchdog task on every Julia worker process.

Each worker starts an OS-level watchdog that kills the worker if its parent PID
changes. This is more reliable than a Julia task when the worker is idle in
Distributed internals. Each worker also periodically sends a heartbeat to process
`1`, the Julia master process. If the heartbeat times out or fails, the worker
exits itself.
"""
function install_parent_process_watchdog()
    # The values are bundled in a named tuple so they are serialized to workers
    # as one argument. Passing multiple arguments to a freshly defined anonymous
    # remote function can hit Julia world-age issues.
    heartbeatConfig = (
        intervalSeconds = 5.0,
        masterPid = getpid(),
        timeoutSeconds = 30.0,
    )

    for workerId in get_worker_ids()
        # Start one watchdog task on each worker. If this file is included more
        # than once, the guard below avoids stacking several watchdog loops on
        # the same worker.
        remotecall_wait(workerId, heartbeatConfig) do config
            intervalSeconds = config.intervalSeconds
            masterPid = config.masterPid
            timeoutSeconds = config.timeoutSeconds

            if isdefined(Main, :TRAQUER_PARENT_WATCHDOG_STARTED)
                return nothing
            end

            Main.TRAQUER_PARENT_WATCHDOG_STARTED = true

            # OS-level watchdog:
            #
            # The Julia task below is useful, but it is not enough for all local
            # hard-kill cases. In practice, a worker can sit idle inside
            # Distributed internals and not schedule our Julia `@async` task soon
            # after the master process disappears.
            #
            # To avoid that, the worker launches a tiny shell process that only
            # watches this worker's parent PID. If the parent PID changes, the
            # worker has been orphaned/re-parented, so the shell kills it.
            #
            # This is local to the worker machine. For a remote worker, it still
            # helps if the remote launcher/SSH parent disappears. If not, the
            # Distributed heartbeat below remains the cross-machine fallback.
            workerPid = getpid()
            parentPid = ccall(:getppid, Cint, ())
            watchdogScript = """
                while [ \"\$(ps -o ppid= -p $workerPid | tr -d ' ')\" = \"$parentPid\" ]; do
                    sleep 5
                done

                kill -TERM $workerPid 2>/dev/null || true
                sleep 5
                kill -KILL $workerPid 2>/dev/null || true
            """
            Main.TRAQUER_OS_PARENT_WATCHDOG_PROCESS = run(
                pipeline(`sh -c $watchdogScript`; stdout=devnull, stderr=devnull),
                wait=false,
            )

            # Julia-level watchdog:
            #
            # The heartbeat is less dependent on local process relationships and
            # is therefore useful for remote workers. Every worker asks process 1
            # on the Julia cluster to answer a trivial request. If process 1 is
            # gone or unreachable, the worker exits itself.
            Main.TRAQUER_PARENT_WATCHDOG_TASK = errormonitor(@async begin
                initialParentPid = ccall(:getppid, Cint, ())

                # For local workers created by `addprocs(n)`, the OS parent PID
                # usually equals the master's PID. For remote workers, PID values
                # belong to different machines/namespaces, so this comparison is
                # expected to be false and the heartbeat below does the work.
                tracksLocalParent = initialParentPid == masterPid

                while true
                    if tracksLocalParent && ccall(:getppid, Cint, ()) != masterPid
                        @warn (
                            "Local parent Julia process disappeared; "
                            * "exiting worker"
                        ) myid()
                        exit(0)
                    end

                    # Run the heartbeat in its own task so `timedwait` can put a
                    # hard upper bound on how long we wait for the master. A
                    # plain `remotecall_fetch` could block forever on a broken
                    # connection depending on the failure mode.
                    heartbeatTask = @async remotecall_fetch(() -> true, 1)
                    waitResult = timedwait(
                        () -> istaskdone(heartbeatTask),
                        timeoutSeconds,
                    )

                    if waitResult == :timed_out
                        @warn (
                            "Parent Julia process did not answer heartbeat; "
                            * "exiting worker"
                        ) myid()
                        exit(0)
                    end

                    try
                        fetch(heartbeatTask)
                    catch err
                        @warn (
                            "Parent Julia process disappeared; exiting worker"
                        ) myid() exception = err
                        exit(0)
                    end

                    sleep(intervalSeconds)
                end
            end)

            return nothing
        end
    end

    return nothing
end

# Graceful shutdown path: when the main Julia process exits normally, ask
# Distributed to remove workers cleanly. The watchdog above covers hard kills.
if !isdefined(Main, :TRAQUER_WORKER_CLEANUP_REGISTERED)
    Main.TRAQUER_WORKER_CLEANUP_REGISTERED = true

    atexit(() -> begin
        workerIds = get_worker_ids()
        if isempty(workerIds)
            return nothing
        end

        try
            rmprocs(workerIds...; waitfor=5.0)
        catch err
            @warn "Failed to remove Julia workers during shutdown" exception = err
        end

        return nothing
    end)
end

# We want this to be explicitly set in the configuration. Requiring an explicit
# value avoids accidentally starting more workers than expected from a REPL,
# scheduled task, or VS Code Julia session.
if !haskey(ENV, "ADDITIONAL_PROCS_NUMBER")
    error(
        "Missing environment variable[ADDITIONAL_PROCS_NUMBER]."
        * " You can add it in ~/.julia/config/startup.jl",
    )
end

numberOfProcsToBeAdded = parse(Int, ENV["ADDITIONAL_PROCS_NUMBER"])

# `nprocs()` includes the main process, hence the `+ 1` comparison.
if numberOfProcsToBeAdded > 0 && nprocs() < numberOfProcsToBeAdded + 1
    @info "Adding $numberOfProcsToBeAdded workers"
    addprocs(numberOfProcsToBeAdded)
else
    @info (
        "Required number of workers ($numberOfProcsToBeAdded) already present. "
        * "No additional workers added."
    )
end

# Install after workers have been created so every worker gets the watchdog.
install_parent_process_watchdog()
