include("../runtests-prerequisite.jl")

@testset "Test SchedulerCtrl.getMaxProcessingTime" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        SchedulerCtrl.getMaxProcessingTime(dbconn)
    end

end
