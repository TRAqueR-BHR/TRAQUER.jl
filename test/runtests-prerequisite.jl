include("../scripts/prerequisite.jl")

using Test, Mocking, UUIDs, LibPQ, Random, JSON, XLSX

function getDefaultEncryptionStr()
    return "aaaaaaaxxxxxcccccc"
end

function getRandomPatient(dbconn::LibPQ.Connection)
    "SELECT * FROM patient LIMIT 1" |>
    n -> PostgresORM.execute_query_and_handle_result(n, Patient,missing,false,dbconn) |>
    first
end

nothing
