include("prerequisite.jl")

dumpFilePath = joinpath(
    "/home/medilegist/CODE/TRAQUER.jl/misc/dev-database-dumps",
    "medilegist-$projectVersion.dump"
)
TRAQUERUtil.dumpDatabase(;dumpFilePath = dumpFilePath)
