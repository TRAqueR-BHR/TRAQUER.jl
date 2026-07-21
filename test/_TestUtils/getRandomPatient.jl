function _TestUtils.getRandomPatient(dbconn::LibPQ.Connection)
    "SELECT * FROM patient LIMIT 1" |>
    n -> PostgresORM.execute_query_and_handle_result(n, Patient, missing, false, dbconn) |>
    first
end
