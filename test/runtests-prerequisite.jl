using Revise
include("../scripts/prerequisite.jl")

using Test, Mocking, UUIDs, LibPQ, Random, JSON, XLSX, Dates, Redis

function getDefaultMasterKeyWords()
    return ["cat", "boat", "rain", "mill", "tree"]
end

function getDefaultEncryptionStr()
    words = getDefaultMasterKeyWords()
    return MasterKeyCtrl.generateMasterKeyFromWords(words)
end

function getRandomPatient(dbconn::LibPQ.Connection)
    "SELECT * FROM patient LIMIT 1" |>
    n -> PostgresORM.execute_query_and_handle_result(n, Patient,missing,false,dbconn) |>
    first
end

include("_TestUtils/_TestUtils.jl")
using ._TestUtils

nothing
