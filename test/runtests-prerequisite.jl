include("../scripts/prerequisite.jl")

using Test, Mocking, UUIDs, LibPQ, Random, JSON, XLSX

function getDefaultEncryptionStr()
    return "aaaaaaaxxxxxcccccc"
end

nothing
