include("../runtests-prerequisite.jl")

@testset "Test TaskWaitingForUserExecutionCtrl.checkIfAnyPendingTask" begin

    dbconn = MedilegistUtil.openDBConn()
    TaskWaitingForUserExecutionCtrl.checkIfAnyPendingTask(dbconn)
    MedilegistUtil.closeDBConn(dbconn)

end
