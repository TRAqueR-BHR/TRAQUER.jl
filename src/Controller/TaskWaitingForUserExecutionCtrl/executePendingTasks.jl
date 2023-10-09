function TaskWaitingForUserExecutionCtrl.executePendingTasks(encryptionStr::String)

    tasks::Vector{TaskWaitingForUserExecution} =
        TaskWaitingForUserExecutionCtrl.getPendingTasksAndSetAsStarted()

    for t in tasks
        try
            fct = TRAQUERUtil.getJuliaFunction(t.name)
            executeOnBgThread() do
                fct(encryptionStr)
            end
            t.success = true
        catch e
            t.success = false
            t.errorMsg = TRAQUERUtil.formatExceptionAndStackTraceCore(
                e, stacktrace(catch_backtrace())
            )
        finally
            t.endOrErrorTime = now(getTimeZone())
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.update_entity!(t,dbconn)
            end
        end
    end

end
