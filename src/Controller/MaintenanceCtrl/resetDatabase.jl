function MaintenanceCtrl.resetDatabase()
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        MaintenanceCtrl.resetDatabase(dbconn)
    end
end

function MaintenanceCtrl.resetDatabase(dbconn::LibPQ.Connection)

    if !TRAQUERUtil.resetDatabaseIsAllowed()
        error(
            "You are trying to reset the database. The configuration doesnt allow that."
            *" If you really want to reset the database, set `allow_database_reset = true`"
            *" in the 'debug' section of the configuration file"
        )
    end

    # "DELETE FROM stay" |>
    # n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM analysis_result" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM infectious_status" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM outbreak" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM contact_exposure" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

end
