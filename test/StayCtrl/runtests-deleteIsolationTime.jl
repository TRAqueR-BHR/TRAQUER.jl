include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.deleteIsolationTime" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        StayCrl.deleteIsolationTime(Stay(id = "xxxxxxxxx"), dbconn)
    end

end
