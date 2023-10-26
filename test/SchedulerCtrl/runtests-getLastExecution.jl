include("../runtests-prerequisite.jl")

@testset "Test SchedulerCtrl.getLastExecution" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        SchedulerCtrl.getLastExecution(
            TRAQUERUtil.getJuliaFunction("TRAQUER.Controller.ETLCtrl.createPendingTask"),
            dbconn
        )
    end

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        SchedulerCtrl.getLastExecution(
            TRAQUER.Controller.EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents,
            dbconn
        )
    end

end
