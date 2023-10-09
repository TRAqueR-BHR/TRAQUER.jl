function TaskWaitingForUserExecutionCtrl.checkIfAnyPendingTask(dbconn::LibPQ.Connection)::Bool

    # https://www.dbrnd.com/2017/01/postgresql-how-to-apply-access-exclusive-lock-mode-on-table-share-lock-update-lock-row-lock/


    queryString = "
        SELECT t.*
        FROM misc.task_waiting_for_user_execution t
        WHERE t.start_time IS NULL"

    df = PostgresORM.execute_plain_query(
        queryString,
        missing,
        dbconn
    )

    if isempty(df)
        return false
    else
        return true
    end

end
