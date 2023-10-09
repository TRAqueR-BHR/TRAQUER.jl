function SchedulerCtrl.checkIfNeedsToExecuteFunction(
    _module::Module,
    _functionName::Symbol,
    _execution_times::Vector{Time}
)

      queryString = "SELECT start_time
                     FROM misc.scheduled_task_execution
                     WHERE name = \$1
                     ORDER BY start_time DESC
                     LIMIT 1"

      _now = now(getTimeZone())

      # Loop over the expected execution times and check if we are less than one
      #   minute away
      for _time in _execution_times

            timediff = (Time(_now) - _time) / Nanosecond(1000000000)

            # @info "timediff[$timediff]"

            if (timediff < 0 || timediff > 60) continue end

            # If we are less than 60 seconds after the expected execution time
            #  check that there was no other execution started for this function
            #  within the last minute.
            # Indeed we check every 45s seconds if there is something to execute
            #  so suppose the expectedExecutionTime is 19:12:00 and that we check
            #  a first time at 19:12:03 and we trigger the execution, 45seconds
            #  later (i.e.  at 19:12:48 we are still less than 60s away from the
            #  execution time)
            functionFullname = string(_module,".",_functionName)

            lastExecution = TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.execute_plain_query(
                    queryString,
                    [functionFullname],
                    dbconn
                )
            end

            if !isempty(lastExecution)
                lastExecution = lastExecution[1,:start_time]

                timediffWithLastExecution =
                    (_now - lastExecution) / Millisecond(1000)
                # @info "timediffWithLastExecution[$timediffWithLastExecution]"
                if timediffWithLastExecution < 60
                    # @info (
                    #   "We already started an execution for"
                    #  *" function[$functionFullname] at [$lastExecution]")

                    continue
                end
            end

            scheduledTaskExecution = ScheduledTaskExecution(
                name = functionFullname,
                startTime = _now
            )
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.create_entity!(scheduledTaskExecution,dbconn)
            end

            # Prepare the function for execution
            fct = getfield(_module, _functionName)

            # Execute the function on a background thread
            executeOnBgThread() do
                try
                    fct()
                catch e
                    formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
                end
            end

      end

end
