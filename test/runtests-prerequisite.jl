using Pkg
Pkg.activate(".")

using Revise

using TRAQUER

# Ajout du chemin vers PostgresORM dans le path de julia
# push!(LOAD_PATH, ENV["PostgresORM_PATH"])

using Distributed
include("../src/using.jl")


using PostgresORM
using CSV, XLSX
using  XLSX
using DataFrames
using TimeZones
using Dates
using Test

function getDefaultEncryptionStr()
    return "aaaaaaaxxxxxcccccc"
end

@everywhere include("../src/logging/loggers.jl")
