function Custom.resetData(
    dbconn::LibPQ.Connection
)

    # TODO: Add a security with a configuration to prevent invoking it by mistake

    "DELETE FROM infectious_status" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM outbreak" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM contact_exposure" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "UPDATE stay SET sys_processing_time = NULL" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "UPDATE analysis_result SET sys_processing_time = NULL" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    return true

end
