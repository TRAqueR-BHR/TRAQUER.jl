include("../runtests-prerequisite.jl")

@testset "Test TaskWaitingForUserExecutionCtrl.createPendingTask" begin

    dbconn = TRAQUERUtil.openDBConn()
    t = TaskWaitingForUserExecutionCtrl.createPendingTask("myfunction1",dbconn)
    PostgresORM.delete_entity(t, dbconn)
    TRAQUERUtil.closeDBConn(dbconn)

end
