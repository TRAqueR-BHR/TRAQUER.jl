include("../runtests-prerequisite.jl")

@testset "Test TaskWaitingForUserExecutionCtrl.createPendingTask" begin

    dbconn = MedilegistUtil.openDBConn()
    t = TaskWaitingForUserExecutionCtrl.createPendingTask("myfunction1",dbconn)
    PostgresORM.delete_entity(t, dbconn)
    MedilegistUtil.closeDBConn(dbconn)

end
