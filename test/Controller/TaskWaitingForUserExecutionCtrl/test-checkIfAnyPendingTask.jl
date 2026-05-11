include("../__prerequisite.jl")

@testset "Test TaskWaitingForUserExecutionCtrl.checkIfAnyPendingTask" begin

    dbconn = TRAQUERUtil.openDBConn()
    TaskWaitingForUserExecutionCtrl.checkIfAnyPendingTask(dbconn)
    TRAQUERUtil.closeDBConn(dbconn)

end
