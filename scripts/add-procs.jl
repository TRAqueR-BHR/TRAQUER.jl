# Add the configured number of Julia worker processes.
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

Each worker periodically sends a heartbeat to process `1`, the Julia master
process. If the heartbeat times out or fails, the worker exits itself. This
prevents orphaned workers when the master process is killed abruptly, and works
for both local and remote Julia workers.
"""
function install_parent_process_watchdog()
    heartbeatConfig = (
        intervalSeconds = 5.0,
        timeoutSeconds = 30.0,
    )

    for workerId in get_worker_ids()
        # Start one watchdog task on each worker. If this file is included more
        # than once, the guard below avoids stacking several watchdog loops on
        # the same worker.
        remotecall_wait(workerId, heartbeatConfig) do config
            intervalSeconds = config.intervalSeconds
            timeoutSeconds = config.timeoutSeconds

            if isdefined(Main, :TRAQUER_PARENT_WATCHDOG_STARTED)
                return nothing
            end

            Main.TRAQUER_PARENT_WATCHDOG_STARTED = true
            Main.TRAQUER_PARENT_WATCHDOG_TASK = errormonitor(@async begin
                # Use a Distributed heartbeat instead of checking the OS parent
                # PID. OS PIDs only work for local workers; this also works when
                # workers run on other machines through Julia's cluster support.
                while true
                    heartbeatTask = @async remotecall_fetch(() -> true, 1)
                    waitResult = timedwait(() -> istaskdone(heartbeatTask), timeoutSeconds)

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
# Distributed to remove workers cleanly. The heartbeat above covers hard kills.
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

# We want this to be explicitly set in the configuration
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
