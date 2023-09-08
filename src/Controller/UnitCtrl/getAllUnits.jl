function UnitCtrl.getAllUnits(retrieveComplexValues::Bool, dbconn::LibPQ.Connection)::Vector{Unit}

    units = "SELECT DISTINCT u.* FROM unit u" |>
    n -> PostgresORM.execute_query_and_handle_result(
        n, Unit, missing, retrieveComplexValues, dbconn
    )

    return units

end
