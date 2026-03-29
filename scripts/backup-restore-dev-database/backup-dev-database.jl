include("prerequisite.jl")

dumpFilePath = joinpath(
    "/home/traquer/CODE/TRAQUER.jl/misc/dev-database-dumps",
    "traquer-$projectVersion.dump"
)
TRAQUERUtil.dumpDatabase(;dumpFilePath = dumpFilePath)
