function TaskWaitingForUserExecutionCtrl.executePendingTasks(encryptionStr::String)

    tasks::Vector{TaskWaitingForUserExecution} =
        TaskWaitingForUserExecutionCtrl.getPendingTasksAndSetAsStarted()


    for t in tasks

        # Function may have been blacklisted
        if ("$(string(f._module)).$(string(f._functionName))" ∈ TRAQUERUtil.getSchedulerBlacklist())
            continue
        end

        try
            fct = TRAQUERUtil.getJuliaFunction(t.name)
            executeOnBgThread() do
                fct(encryptionStr)
            end
            t.success = true
        catch e

            # Update instance of TaskWaitingForUserExecution
            t.success = false
            errorMsg = TRAQUERUtil.formatExceptionAndStackTraceCore(
                e, stacktrace(catch_backtrace())
            )
            t.errorMsg = errorMsg

            # Notify admin of error
            TRAQUERUtil.notifyAdmin(
                "Error in $(TRAQUERUtil.getInstanceCodeName()) (executePendingTasks)" ,
                errorMsg
            )

        finally
            t.endOrErrorTime = now(getTimeZone())
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.update_entity!(t,dbconn)
            end
        end
    end

end
