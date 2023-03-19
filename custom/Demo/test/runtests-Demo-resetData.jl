include("../../../test/runtests-prerequisite.jl")

TRAQUERUtil.createDBConnAndExecute() do dbconn
    TRAQUER.Custom.resetData(dbconn)
end
