include("prerequisite.jl")

dumpFilePath = joinpath(
    "/home/traquer/CODE/TRAQUER.jl/misc/dev-database-dumps",
    "traquer-schema-$projectVersion.dump"
)
TRAQUERUtil.dumpDatabase(
    ;dumpFilePath = dumpFilePath,
    schemaOnly = true
)
