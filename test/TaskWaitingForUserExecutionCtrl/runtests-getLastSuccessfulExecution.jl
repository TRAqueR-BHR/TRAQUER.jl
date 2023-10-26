include("../runtests-prerequisite.jl")

@testset "Test TaskWaitingForUserExecutionCtrl.getLastSuccessfulExecution" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        TaskWaitingForUserExecutionCtrl.getLastSuccessfulExecution(
            TRAQUER.Controller.ETLCtrl.integrateAndProcessNewStaysAndAnalyses,
            dbconn
        )
    end

end
