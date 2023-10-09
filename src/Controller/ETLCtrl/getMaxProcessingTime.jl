function ETLCtrl.getMaxProcessingTime(dbconn::LibPQ.Connection)::ZonedDateTime

    maxTime = "SELECT max_time FROM misc.max_processing_time" |>
        n -> PostgresORM.execute_plain_query(n, missing, dbconn) |>
        n -> begin
            if isempty(n)
                error("Table misc.max_processing_time is empty")
            else
                n[1,"max_time"]
            end
        end

    return maxTime

end
