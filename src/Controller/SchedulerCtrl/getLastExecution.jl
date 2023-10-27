function SchedulerCtrl.getLastExecution(fct::Function, dbconn::LibPQ.Connection)

    tasks = "
        SELECT t.*
        FROM misc.scheduled_task_execution t
        WHERE t.name = \$1
        ORDER BY t.start_time DESC
        LIMIT 1
        " |> n -> PostgresORM.execute_query_and_handle_result(
            n,
            ScheduledTaskExecution,
            [
                "$(parentmodule(fct)).$(nameof(fct))"
            ],
            false,
            dbconn
        )

    if isempty(tasks)
        return missing
    end

    return first(tasks)


end
