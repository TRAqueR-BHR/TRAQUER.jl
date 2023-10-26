function SchedulerCtrl.checkIfAnythingNeedsToBeExecuted()

    # This is where you declare the functions and the times of execution
    functions = [
        # TODO
        # (
        #     _module = DeviceCtrl,
        #     _functionName = :lockInactiveUsers,
        #     _execution_times = SchedulerCtrl.every2Minutes
        # ),
        # TODO
        # (
        #     _module = TRAQUERUtil,
        #     _functionName = :dumpDatabaseAndCleanOldDumps,
        #     _execution_times = SchedulerCtrl.every2Hours
        # ),
        (
            _module = ETLCtrl,
            _functionName = :createPendingTask,
            _execution_times = SchedulerCtrl.every5Minutes
        ),
        (
            _module = EventRequiringAttentionCtrl,
            _functionName = :notifyTeamOfNewImportantEvents,
            _execution_times = SchedulerCtrl.every5Minutes
        ),
        (
            _module = TRAQUER,
            _functionName = :greet,
            _execution_times = SchedulerCtrl.every1Minutes
        )
    ]

    for f in functions

        # Function may have been blacklisted
        if ("$(string(f._module)).$(string(f._functionName))" ∈ TRAQUERUtil.getSchedulerBlacklist())
            continue
        end

        SchedulerCtrl.checkIfNeedsToExecuteFunction(
            f._module,
            f._functionName,
            f._execution_times
        )
    end

end
