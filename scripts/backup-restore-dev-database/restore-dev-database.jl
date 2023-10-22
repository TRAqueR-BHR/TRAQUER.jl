include("prerequisite.jl")


dumpFilename = "/home/medilegist/CODE/TRAQUER.jl/misc/dev-database-dumps/medilegist-$projectVersion.dump"

restoreDevDatabase(TRAQUERUtil.getConf("database","database"))
TRAQUERUtil.overwriteConfWithBlindBakeConf()
restoreDevDatabase(TRAQUERUtil.getConf("database","database"))
TRAQUERUtil.restoreConf()
