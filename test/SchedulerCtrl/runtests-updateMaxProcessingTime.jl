include("../runtests-prerequisite.jl")

@testset "Test SchedulerCtrl.updateMaxProcessingTime" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        SchedulerCtrl.updateMaxProcessingTime(dbconn)
    end

end
