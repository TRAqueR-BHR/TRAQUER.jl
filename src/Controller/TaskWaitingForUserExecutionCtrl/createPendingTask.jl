function TaskWaitingForUserExecutionCtrl.createPendingTask(functionName::String, dbconn::LibPQ.Connection)


    t = TaskWaitingForUserExecution(
        name = functionName,
        creationTime = now(getTimeZone())
    )

    PostgresORM.create_entity!(t, dbconn)

end
