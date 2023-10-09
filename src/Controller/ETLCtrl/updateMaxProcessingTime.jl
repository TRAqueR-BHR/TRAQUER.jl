function ETLCtrl.updateMaxProcessingTime(dbconn::LibPQ.Connection)::ZonedDateTime

    # Get the max processing time from the analysis table (NOTE: could also use the stay table)
    maxProcessingTime = "
        SELECT max(sys_processing_time) FROM analysis_result" |>
        n -> PostgresORM.execute_plain_query(n, missing, dbconn) |>
        n -> n[1,1]

    # Clear table
    "DELETE FROM misc.max_processing_time" |>
        n -> PostgresORM.execute_plain_query(n, missing, dbconn)

    # Insert new singleton row
    "INSERT INTO misc.max_processing_time (max_time) VALUES (\$1)" |>
        n -> PostgresORM.execute_plain_query(n, [maxProcessingTime], dbconn)

    return maxProcessingTime

end
