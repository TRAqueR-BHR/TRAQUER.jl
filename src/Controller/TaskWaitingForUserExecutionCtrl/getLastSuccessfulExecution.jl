function TaskWaitingForUserExecutionCtrl.getLastSuccessfulExecution(
    fct::Function,
    dbconn::LibPQ.Connection
)

    tasks = "
        SELECT t.*
        FROM misc.task_waiting_for_user_execution t
        WHERE t.name = \$1
        AND t.end_or_error_time IS NOT NULL
        AND t.error_msg IS NULL
        ORDER BY t.end_or_error_time DESC
        LIMIT 1
        " |> n -> PostgresORM.execute_query_and_handle_result(
            n,
            TaskWaitingForUserExecution,
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
