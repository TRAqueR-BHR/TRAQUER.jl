include("../runtests-prerequisite.jl")

@testset "Test SchedulerCtrl.processNewlyIntegratedData" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        SchedulerCtrl.processNewlyIntegratedData(dbconn)
    end

end
