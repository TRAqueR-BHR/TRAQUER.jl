include("prerequisite.jl")
using CSV, DataFrames
using TRAQUER, TRAQUER.TRAQUERUtil

# Cleaning
MaintenanceCtrl.resetDatabase(resetStays = true)

@time TRAQUER.Custom.importStays(
    "/home/traquer/DATA/pending/dxcare-from-2022-12-01-00-00-00-to-2023-01-01-00-00-00.csv",
    "/home/traquer/CODE/TRAQUER.jl/tmp/problems",
    getDefaultEncryptionStr(),
    # ;maxNumberOfLinesToIntegrate = 10
)

@time TRAQUER.Custom.importAnalyses(
    "/home/traquer/DATA/pending/inlog-3mois.csv",
    "/home/traquer/CODE/TRAQUER.jl/tmp/problems",
    getDefaultEncryptionStr(),
    ;maxNumberOfLinesToIntegrate = 1000
)
